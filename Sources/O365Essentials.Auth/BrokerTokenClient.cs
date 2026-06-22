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
        bool forcePrompt)
    {
        var scopeCandidates = BuildScopeCandidatesFromResource(resourceUrl);
        return AcquireTokenAsync(tenant, scopeCandidates, clientId, forcePrompt).GetAwaiter().GetResult();
    }

    public static BrokerTokenResult AcquireTokenForScope(
        string? tenant,
        string scope,
        string clientId,
        bool forcePrompt)
    {
        var scopes = SplitScopes(scope);
        if (scopes.Length == 0)
        {
            throw new ArgumentException("At least one scope must be provided.", nameof(scope));
        }

        return AcquireTokenAsync(tenant, new[] { scopes }, clientId, forcePrompt).GetAwaiter().GetResult();
    }

    private static async Task<BrokerTokenResult> AcquireTokenAsync(
        string? tenant,
        IReadOnlyList<string[]> scopeCandidates,
        string clientId,
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
                var result = await AcquireTokenForScopesAsync(application, scopes, forcePrompt).ConfigureAwait(false);
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
        bool forcePrompt)
    {
        if (!forcePrompt)
        {
            var accounts = await application.GetAccountsAsync().ConfigureAwait(false);
            foreach (var account in accounts)
            {
                try
                {
                    return await application.AcquireTokenSilent(scopes, account).ExecuteAsync().ConfigureAwait(false);
                }
                catch (MsalUiRequiredException)
                {
                }
            }

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

        return await application
            .AcquireTokenInteractive(scopes)
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

    private static IntPtr GetConsoleOrTerminalWindow()
    {
        var consoleHandle = GetConsoleWindow();
        return consoleHandle == IntPtr.Zero
            ? IntPtr.Zero
            : GetAncestor(consoleHandle, GetAncestorFlags.GetRootOwner);
    }

    private enum GetAncestorFlags
    {
        GetRootOwner = 3
    }

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", ExactSpelling = true)]
    private static extern IntPtr GetAncestor(IntPtr hwnd, GetAncestorFlags flags);
}
