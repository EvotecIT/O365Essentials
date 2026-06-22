using Microsoft.Identity.Client;
using Microsoft.Identity.Client.Broker;
using System.Runtime.InteropServices;

namespace O365Essentials.Auth;

public sealed class BrokerTokenResult
{
    public string AccessToken { get; init; } = string.Empty;

    public DateTimeOffset ExpiresOn { get; init; }

    public string? TenantId { get; init; }

    public string? AccountUsername { get; init; }

    public string[] Scopes { get; init; } = Array.Empty<string>();
}

public static class BrokerTokenClient
{
    private const string DefaultAuthorityTenant = "organizations";

    public static BrokerTokenResult AcquireTokenForResource(
        string? tenant,
        string resourceUrl,
        string clientId,
        string? accountUsername,
        bool forcePrompt)
    {
        var scopeCandidates = BuildScopeCandidatesFromResource(resourceUrl);
        return AcquireTokenAsync(tenant, scopeCandidates, clientId, accountUsername, forcePrompt).GetAwaiter().GetResult();
    }

    public static BrokerTokenResult AcquireTokenForScope(
        string? tenant,
        string scope,
        string clientId,
        string? accountUsername,
        bool forcePrompt)
    {
        var scopes = SplitScopes(scope);
        if (scopes.Length == 0)
        {
            throw new ArgumentException("At least one scope must be provided.", nameof(scope));
        }

        return AcquireTokenAsync(tenant, new[] { scopes }, clientId, accountUsername, forcePrompt).GetAwaiter().GetResult();
    }

    private static async Task<BrokerTokenResult> AcquireTokenAsync(
        string? tenant,
        IReadOnlyList<string[]> scopeCandidates,
        string clientId,
        string? accountUsername,
        bool forcePrompt)
    {
        if (!OperatingSystem.IsWindows())
        {
            throw new PlatformNotSupportedException("MSAL WAM broker authentication is supported only on Windows.");
        }

        if (string.IsNullOrWhiteSpace(clientId))
        {
            throw new ArgumentException("ClientId is required.", nameof(clientId));
        }

        if (scopeCandidates.Count == 0)
        {
            throw new ArgumentException("At least one scope candidate is required.", nameof(scopeCandidates));
        }

        var authorityTenant = string.IsNullOrWhiteSpace(tenant) ? DefaultAuthorityTenant : tenant.Trim();
        var brokerOptions = new BrokerOptions(BrokerOptions.OperatingSystems.Windows)
        {
            Title = "O365Essentials"
        };

        var application = PublicClientApplicationBuilder
            .Create(clientId.Trim())
            .WithAuthority($"https://login.microsoftonline.com/{authorityTenant}")
            .WithDefaultRedirectUri()
            .WithParentActivityOrWindow(GetConsoleOrTerminalWindow)
            .WithBroker(brokerOptions)
            .Build();

        Exception? lastFailure = null;
        foreach (var scopes in scopeCandidates)
        {
            try
            {
                var result = await AcquireTokenForScopesAsync(application, scopes, accountUsername, forcePrompt).ConfigureAwait(false);
                EnsureAccountMatches(result, accountUsername);
                return ToResult(result);
            }
            catch (MsalException ex) when (CanTryNextScopeCandidate(ex))
            {
                lastFailure = ex;
            }
            catch (ArgumentException ex)
            {
                lastFailure = ex;
            }
        }

        throw new InvalidOperationException("MSAL WAM token acquisition failed for all configured scope candidates.", lastFailure);
    }

    private static async Task<AuthenticationResult> AcquireTokenForScopesAsync(
        IPublicClientApplication application,
        string[] scopes,
        string? accountUsername,
        bool forcePrompt)
    {
        var expectedUsername = string.IsNullOrWhiteSpace(accountUsername) ? null : accountUsername.Trim();
        if (!forcePrompt)
        {
            var accounts = await application.GetAccountsAsync().ConfigureAwait(false);
            var candidateAccounts = string.IsNullOrWhiteSpace(expectedUsername)
                ? accounts
                : accounts.Where(account =>
                    !string.IsNullOrWhiteSpace(account.Username)
                    && account.Username.Equals(expectedUsername, StringComparison.OrdinalIgnoreCase));

            foreach (var account in candidateAccounts)
            {
                try
                {
                    return await application.AcquireTokenSilent(scopes, account).ExecuteAsync().ConfigureAwait(false);
                }
                catch (MsalUiRequiredException)
                {
                }
            }

            if (string.IsNullOrWhiteSpace(expectedUsername))
            {
                try
                {
                    return await application
                        .AcquireTokenSilent(scopes, PublicClientApplication.OperatingSystemAccount)
                        .ExecuteAsync()
                        .ConfigureAwait(false);
                }
                catch (MsalUiRequiredException)
                {
                }
            }
        }

        var interactiveBuilder = application
            .AcquireTokenInteractive(scopes);
        if (!string.IsNullOrWhiteSpace(expectedUsername))
        {
            interactiveBuilder = interactiveBuilder.WithLoginHint(expectedUsername);
        }

        return await interactiveBuilder
            .WithPrompt(Prompt.SelectAccount)
            .ExecuteAsync()
            .ConfigureAwait(false);
    }

    private static BrokerTokenResult ToResult(AuthenticationResult result)
    {
        return new BrokerTokenResult
        {
            AccessToken = result.AccessToken,
            ExpiresOn = result.ExpiresOn,
            TenantId = result.TenantId ?? result.Account?.HomeAccountId?.TenantId,
            AccountUsername = result.Account?.Username,
            Scopes = result.Scopes?.ToArray() ?? Array.Empty<string>()
        };
    }

    private static string[][] BuildScopeCandidatesFromResource(string resourceUrl)
    {
        if (string.IsNullOrWhiteSpace(resourceUrl))
        {
            throw new ArgumentException("ResourceUrl is required.", nameof(resourceUrl));
        }

        var resource = resourceUrl.Trim();
        if (resource.Contains(' ', StringComparison.Ordinal))
        {
            return new[] { SplitScopes(resource) };
        }

        if (Guid.TryParse(resource, out _))
        {
            return new[]
            {
                new[] { resource + "/.default" },
                new[] { "api://" + resource + "/.default" }
            };
        }

        return new[] { new[] { resource.TrimEnd('/') + "/.default" } };
    }

    private static string[] SplitScopes(string value)
    {
        return value
            .Split(new[] { ' ', '\t', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Where(scope => !scope.Equals("offline_access", StringComparison.OrdinalIgnoreCase))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    private static bool CanTryNextScopeCandidate(MsalException exception)
    {
        return exception.ErrorCode.Equals("invalid_scope", StringComparison.OrdinalIgnoreCase)
            || exception.ErrorCode.Equals("invalid_resource", StringComparison.OrdinalIgnoreCase)
            || exception.ErrorCode.Equals("invalid_request", StringComparison.OrdinalIgnoreCase);
    }

    private static void EnsureAccountMatches(AuthenticationResult result, string? expectedUsername)
    {
        if (string.IsNullOrWhiteSpace(expectedUsername) || result.Account is null)
        {
            return;
        }

        if (string.IsNullOrWhiteSpace(result.Account.Username)
            || !result.Account.Username.Equals(expectedUsername.Trim(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException(
                $"MSAL WAM returned account '{result.Account.Username}' while O365Essentials expected '{expectedUsername}'.");
        }
    }

    private static IntPtr GetConsoleOrTerminalWindow()
    {
        var consoleHandle = GetConsoleWindow();
        if (consoleHandle != IntPtr.Zero)
        {
            var owner = GetAncestor(consoleHandle, GetAncestorFlags.GetRootOwner);
            return owner == IntPtr.Zero ? consoleHandle : owner;
        }

        var foregroundHandle = GetForegroundWindow();
        if (foregroundHandle != IntPtr.Zero)
        {
            return foregroundHandle;
        }

        var shellHandle = GetShellWindow();
        if (shellHandle != IntPtr.Zero)
        {
            return shellHandle;
        }

        return GetDesktopWindow();
    }

    private enum GetAncestorFlags
    {
        GetRootOwner = 3
    }

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern IntPtr GetShellWindow();

    [DllImport("user32.dll")]
    private static extern IntPtr GetDesktopWindow();

    [DllImport("user32.dll", ExactSpelling = true)]
    private static extern IntPtr GetAncestor(IntPtr hwnd, GetAncestorFlags flags);
}
