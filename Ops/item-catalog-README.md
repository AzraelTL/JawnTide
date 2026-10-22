# Item catalog (Ops/item-catalog.tsv)

The Loot Editor's **Items** tab lists every item that could be put on a vendor. Content's own items are always
there; the rest of the game's items come from `Ops/item-catalog.tsv`, an export of the live server's world database
(one line per weenie that has an ItemType: WCID, weenie type, item type, Value, name). The editor leaves out
creatures, portals and lifestones. Without the file the Items tab shows Content items only.

## Refresh it (after a world database change)

1. Linux, in the terminal (the password stays inside the container):

       cd ~/jawntide-server && docker compose exec -T ace-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -B ace_world -e "select w.class_Id, w.type, it.value, coalesce(v.value,0), n.value from weenie w join weenie_properties_int it on it.object_Id=w.class_Id and it.type=1 left join weenie_properties_int v on v.object_Id=w.class_Id and v.type=19 left join weenie_properties_string n on n.object_Id=w.class_Id and n.type=1 where it.value<>0 order by w.class_Id"' > ~/item-catalog.tsv && wc -l ~/item-catalog.tsv

2. NEW PC, Command Prompt (asks for the Linux password):

       scp superuser@192.168.0.190:item-catalog.tsv C:\Users\kylei\source\repos\JawnTide\Ops\item-catalog.tsv

3. Reload in the Loot Editor, then commit the file on a branch like any other change.
