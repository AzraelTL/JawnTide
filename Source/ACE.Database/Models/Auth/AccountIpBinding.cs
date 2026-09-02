using System;

namespace ACE.Database.Models.Auth;

public partial class AccountIpBinding
{
    public uint Id { get; set; }

    public uint AccountId { get; set; }

    /// <summary>
    /// An IP address (IPv4 or IPv6) associated with this account.
    /// An account may accumulate many IP rows over time; a single IP may be bound to more than one
    /// account only up to the configured ip_binding_ip_allowance (default 1 = one account per IP).
    /// </summary>
    public string IpAddress { get; set; }

    public DateTime BoundAt { get; set; }

    /// <summary>
    /// "login" when bound automatically on first login; "admin" when set by an admin command.
    /// </summary>
    public string BoundBy { get; set; }
}
