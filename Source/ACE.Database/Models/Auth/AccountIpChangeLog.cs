using System;

namespace ACE.Database.Models.Auth;

public partial class AccountIpChangeLog
{
    public uint Id { get; set; }

    public uint AccountId { get; set; }

    public string OldIp { get; set; }

    public string NewIp { get; set; }

    public DateTime ChangedAt { get; set; }

    /// <summary>
    /// True when this IP change triggered an automatic ban. Retained for schema compatibility;
    /// the current implementation does not auto-ban on IP change.
    /// </summary>
    public bool AutoBanned { get; set; }

    /// <summary>
    /// True when an admin cleared the binding after this change was logged.
    /// </summary>
    public bool AdminCleared { get; set; }
}
