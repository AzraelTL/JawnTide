-- JawnTide: removes the Ghost Mule system's data from the live databases (run once, GAME SERVER STOPPED, as root).
-- Goes with the commit that reverted the mule system's code and content. Safe to run more than once.
-- Kept: items that were sent to mules (ordinary items in the mule's pack), and the mule's 8th pack slot
-- (AugmentationExtraPackSlot, a stock property), so no packs are stranded.

-- what is being removed (for the record)
SELECT COUNT(*) AS mule_imprint_tokens FROM ace_shard.biota WHERE weenie_Class_Id = 8143004;
SELECT COUNT(*) AS flagged_mules FROM ace_shard.biota_properties_bool WHERE type = 19021 AND value = 1;
SELECT COUNT(*) AS bound_mules FROM ace_shard.biota_properties_i_i_d WHERE type IN (9001, 9002);

-- tokens and any saved ghost (their properties go with them: foreign keys cascade)
DELETE FROM ace_shard.biota WHERE weenie_Class_Id IN (8143004, 8143005);

-- mule flags on characters: IsMuleCharacter, ReceivedMuleImprintToken, MuleImprintMule/Owner, MuleImprintMuleName.
-- Without IsMuleCharacter, former mules earn experience again.
DELETE FROM ace_shard.biota_properties_bool WHERE type IN (19021, 19022);
DELETE FROM ace_shard.biota_properties_i_i_d WHERE type IN (9001, 9002);
DELETE FROM ace_shard.biota_properties_string WHERE type = 9012;

-- the Imprinter NPCs, token and ghost weenies, and the three NPC placements
DELETE FROM ace_world.landblock_instance WHERE guid IN (0x7A9B4F00, 0x7DE51F00, 0x7DA55F00, 0x77D64F00);
DELETE FROM ace_world.weenie WHERE class_Id IN (8143001, 8143002, 8143003, 8143004, 8143005);

-- the Ghost Mules wiki article, if the website already added it
DELETE FROM ace_wiki.revision WHERE slug = 'ghost-mules';
DELETE FROM ace_wiki.page WHERE slug = 'ghost-mules';

SELECT 'Ghost Mule data removed' AS done;
