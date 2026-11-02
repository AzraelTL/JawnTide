namespace ACE.Database.Models.Shard;

/// <summary>
/// My Mule: one row per account, shared by every character on that account. ContainerId is the
/// head of that account's mule storage container chain (0 = not created yet); VisualVariant is
/// the sticky monster-race look rolled the first time any character on the account summons the
/// mule (-1 = not rolled yet).
/// </summary>
public partial class AccountMule
{
    public uint AccountId { get; set; }

    public uint ContainerId { get; set; }

    public int VisualVariant { get; set; }
}
