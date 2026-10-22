using System.Globalization;

namespace LootEditor
{
    public class MainForm : Form
    {
        private class Entry
        {
            public string Path;
            public string TableName;   // set for an NPC reward table
            public bool IsProfile;     // a loot profile (treasure_death) file
            public string Label;
            public bool IsChest => TableName == null && !IsProfile;
            public bool IsBox => TableName == EmoteRewardFile.UseTableName;
            public override string ToString() => Label;
        }

        private class VendorEntry
        {
            public string Path;
            public string Label;
            public uint Wcid;
            public bool IsStock;          // a read-only file in Ops/stock-vendors
            public bool InContent;        // a stock vendor that already has a file in Content
            public override string ToString() => Label;
        }

        private const string LiveTarget = "Content (current stage)";

        private readonly TextBox repoBox = new TextBox { Dock = DockStyle.Fill };
        private readonly Button browseButton = new Button { Text = "Browse...", AutoSize = true };
        private readonly Button reloadButton = new Button { Text = "Reload", AutoSize = true };
        private readonly ComboBox targetBox = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Width = 220 };
        private readonly Button newStageButton = new Button { Text = "New stage...", AutoSize = true };

        // Loot tab: one list per kind of thing, each on its own tab
        private readonly ListBox chestList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly ListBox npcList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly ListBox boxList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly ListBox profileList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly TabControl lootTabs = new TabControl { Dock = DockStyle.Fill };
        private readonly TabControl mainTabs = new TabControl { Dock = DockStyle.Fill };
        private Entry selectedEntry;
        private bool suppressSelect;

        // Vendors tab
        private readonly ListBox vendorList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly ListBox stockVendorList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly TabControl vendorTabs = new TabControl { Dock = DockStyle.Fill };
        private readonly Button copyStockButton = new Button { Text = "Copy into Content to edit", AutoSize = true, Visible = false };
        private readonly Label vendorInfo = new Label { Dock = DockStyle.Top, AutoSize = false, Height = 54 };
        private readonly DataGridView vendorGrid = new DataGridView { Dock = DockStyle.Fill };
        private readonly Label vendorCountLabel = new Label { AutoSize = true, Padding = new Padding(0, 7, 12, 0) };
        private readonly Button vendorAddButton = new Button { Text = "Add item", AutoSize = true };
        private readonly Button vendorRemoveButton = new Button { Text = "Remove selected", AutoSize = true };
        private readonly Button vendorSaveButton = new Button { Text = "Save", AutoSize = true };
        private VendorFile currentVendor;
        private VendorEntry selectedVendor;
        private bool vendorDirty;
        private bool vendorLoading;
        private SplitContainer vendorSplit;
        private readonly Label chestInfo = new Label { Dock = DockStyle.Top, AutoSize = false, Height = 54 };
        private readonly ListBox alwaysList = new ListBox { Dock = DockStyle.Top, Height = 70, IntegralHeight = false };
        private readonly DataGridView fixedGrid = new DataGridView { Dock = DockStyle.Top, Height = 150 };
        private readonly Label alwaysLabel = new Label { Text = "Always generated (not editable here)", Dock = DockStyle.Top, Height = 20 };
        private readonly Label gridLabel = new Label { Dock = DockStyle.Top, Height = 20 };
        private readonly DataGridView grid = new DataGridView { Dock = DockStyle.Fill };
        private readonly Label totalLabel = new Label { AutoSize = true, Padding = new Padding(0, 7, 12, 0) };
        private readonly Button addButton = new Button { Text = "Add item", AutoSize = true };
        private readonly Button removeButton = new Button { Text = "Remove selected", AutoSize = true };
        private readonly Button saveButton = new Button { Text = "Save", AutoSize = true };
        private readonly Button scaleButton = new Button { Text = "Scale to 100%", AutoSize = true };
        private TextBox percentEditBox;

        private readonly WeenieIndex index = new WeenieIndex();
        private readonly List<Entry> entries = new List<Entry>();
        private ChestFile current;
        private EmoteRewardFile currentRewards;
        private LootProfileFile currentProfile;
        private readonly DataGridView profileGrid = new DataGridView { Dock = DockStyle.Fill, Visible = false };
        private bool dirty;
        private bool loadingGrid;
        private object lastTarget;
        private SplitContainer split;

        private static string SettingsPath => Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "JawnTideLootEditor", "settings.txt");

        private string RepoRoot => repoBox.Text.Trim();
        private string ContentSql => Path.Combine(RepoRoot, "Content", "sql");
        private string StagesRoot => Path.Combine(RepoRoot, "Ops", "loot-stages");
        private string StockVendorsRoot => Path.Combine(RepoRoot, "Ops", "stock-vendors");
        private string StockVendorsTarget => Path.Combine(ContentSql, "weenies", "Stock Vendors");

        public MainForm()
        {
            Text = "JawnTide Loot Editor - Loot and Vendors";
            Width = 1150;
            Height = 720;
            StartPosition = FormStartPosition.CenterScreen;

            BuildLayout();
            BuildGrid();
            BuildFixedGrid();
            BuildProfileGrid();
            BuildVendorGrid();

            browseButton.Click += (s, e) => BrowseRepo();
            reloadButton.Click += (s, e) => LoadRepo();
            newStageButton.Click += (s, e) => CreateStage();
            targetBox.SelectedIndexChanged += (s, e) => OnTargetChanged();
            foreach (var list in new[] { chestList, npcList, boxList, profileList })
            {
                var lb = list;
                lb.SelectedIndexChanged += (s, e) => OnListSelected(lb);
            }
            vendorList.SelectedIndexChanged += (s, e) => OnVendorSelected(vendorList);
            stockVendorList.SelectedIndexChanged += (s, e) => OnVendorSelected(stockVendorList);
            copyStockButton.Click += (s, e) => CopyStockVendor();
            vendorAddButton.Click += (s, e) => AddVendorItem();
            vendorRemoveButton.Click += (s, e) => RemoveVendorItems();
            vendorSaveButton.Click += (s, e) => SaveVendor();
            addButton.Click += (s, e) => AddItem();
            removeButton.Click += (s, e) => RemoveSelected();
            saveButton.Click += (s, e) => Save();
            scaleButton.Click += (s, e) => ScaleTo100();
            FormClosing += (s, e) => { if (!ConfirmDiscard() || !ConfirmVendorDiscard()) e.Cancel = true; };

            repoBox.Text = LoadSavedRepo() ?? FindRepoFromExe() ?? "";
            if (Directory.Exists(ContentSql))
                LoadRepo();
        }

        // ---------- layout ----------

        private void BuildLayout()
        {
            var top = new TableLayoutPanel { Dock = DockStyle.Top, Height = 36, ColumnCount = 6, Padding = new Padding(6, 6, 6, 0) };
            top.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            top.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            top.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            top.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            top.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            top.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            top.Controls.Add(new Label { Text = "Repo folder:", AutoSize = true, Padding = new Padding(0, 6, 0, 0) }, 0, 0);
            top.Controls.Add(repoBox, 1, 0);
            top.Controls.Add(browseButton, 2, 0);
            top.Controls.Add(reloadButton, 3, 0);

            var targetPanel = new FlowLayoutPanel { AutoSize = true, WrapContents = false };
            targetPanel.Controls.Add(new Label { Text = "Edit:", AutoSize = true, Padding = new Padding(8, 6, 0, 0) });
            targetPanel.Controls.Add(targetBox);
            top.Controls.Add(targetPanel, 4, 0);
            top.Controls.Add(newStageButton, 5, 0);

            split = new SplitContainer { Dock = DockStyle.Fill };
            Load += (s, e) => { split.SplitterDistance = 340; vendorSplit.SplitterDistance = 340; };
            var titles = new[] { "Chests", "NPC rewards", "Boxes", "Loot profiles" };
            var lists = new[] { chestList, npcList, boxList, profileList };
            for (var t = 0; t < lists.Length; t++)
            {
                var page = new TabPage(titles[t]) { Padding = new Padding(3) };
                page.Controls.Add(lists[t]);
                lootTabs.TabPages.Add(page);
            }
            split.Panel1.Controls.Add(lootTabs);
            split.Panel1.Padding = new Padding(6);

            var bottom = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 38, FlowDirection = FlowDirection.LeftToRight, Padding = new Padding(0, 4, 0, 0) };
            bottom.Controls.Add(totalLabel);
            bottom.Controls.Add(addButton);
            bottom.Controls.Add(removeButton);
            bottom.Controls.Add(scaleButton);
            bottom.Controls.Add(saveButton);

            gridLabel.Font = new Font(Font, FontStyle.Bold);
            alwaysLabel.Font = new Font(Font, FontStyle.Bold);

            split.Panel2.Padding = new Padding(6);
            split.Panel2.Controls.Add(profileGrid);
            split.Panel2.Controls.Add(grid);
            split.Panel2.Controls.Add(gridLabel);
            split.Panel2.Controls.Add(alwaysList);
            split.Panel2.Controls.Add(fixedGrid);
            split.Panel2.Controls.Add(alwaysLabel);
            split.Panel2.Controls.Add(chestInfo);
            split.Panel2.Controls.Add(bottom);

            var lootPage = new TabPage("Loot");
            lootPage.Controls.Add(split);
            mainTabs.TabPages.Add(lootPage);
            var vendorPage = new TabPage("Vendors");
            vendorPage.Controls.Add(BuildVendorLayout());
            mainTabs.TabPages.Add(vendorPage);

            Controls.Add(mainTabs);
            Controls.Add(top);
        }

        private Control BuildVendorLayout()
        {
            vendorSplit = new SplitContainer { Dock = DockStyle.Fill };
            var ownPage = new TabPage("JawnTide vendors") { Padding = new Padding(3) };
            ownPage.Controls.Add(vendorList);
            var stockPage = new TabPage("Stock vendors") { Padding = new Padding(3) };
            stockPage.Controls.Add(stockVendorList);
            vendorTabs.TabPages.Add(ownPage);
            vendorTabs.TabPages.Add(stockPage);
            vendorSplit.Panel1.Controls.Add(vendorTabs);
            vendorSplit.Panel1.Padding = new Padding(6);

            var bottom = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 38, FlowDirection = FlowDirection.LeftToRight, Padding = new Padding(0, 4, 0, 0) };
            bottom.Controls.Add(vendorCountLabel);
            bottom.Controls.Add(vendorAddButton);
            bottom.Controls.Add(vendorRemoveButton);
            bottom.Controls.Add(vendorSaveButton);
            bottom.Controls.Add(copyStockButton);

            var gridTitle = new Label { Text = "Items for sale", Dock = DockStyle.Top, Height = 20, Font = new Font(Font, FontStyle.Bold) };
            vendorSplit.Panel2.Padding = new Padding(6);
            vendorSplit.Panel2.Controls.Add(vendorGrid);
            vendorSplit.Panel2.Controls.Add(gridTitle);
            vendorSplit.Panel2.Controls.Add(vendorInfo);
            vendorSplit.Panel2.Controls.Add(bottom);
            vendorInfo.Text = "Select a vendor on the left.";
            return vendorSplit;
        }

        private void BuildVendorGrid()
        {
            vendorGrid.AllowUserToAddRows = false;
            vendorGrid.AllowUserToDeleteRows = false;
            vendorGrid.RowHeadersVisible = false;
            vendorGrid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            vendorGrid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            vendorGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Wcid", HeaderText = "WCID", FillWeight = 15 });
            vendorGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "ItemName", HeaderText = "Item", FillWeight = 60, ReadOnly = true });
            vendorGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Stack", HeaderText = "Supply (-1 = unlimited)", FillWeight = 25 });
            vendorGrid.CellEndEdit += (s, e) =>
            {
                if (vendorLoading || e.RowIndex < 0)
                    return;
                vendorDirty = true;
                var row = vendorGrid.Rows[e.RowIndex];
                if (vendorGrid.Columns[e.ColumnIndex].Name == "Wcid")
                {
                    var text = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                    row.Cells["ItemName"].Value = uint.TryParse(text, out var wcid)
                        ? index.GetName(wcid) ?? "(not found in Content - check the WCID)"
                        : "(invalid WCID)";
                }
                UpdateVendorCount();
            };
        }

        private void BuildGrid()
        {
            grid.AllowUserToAddRows = false;
            grid.AllowUserToDeleteRows = false;
            grid.RowHeadersVisible = false;
            grid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;

            grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Wcid", HeaderText = "WCID", FillWeight = 15 });
            grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "ItemName", HeaderText = "Item", FillWeight = 50, ReadOnly = true });
            grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Stack", HeaderText = "Stack (-1 = default)", FillWeight = 15 });
            grid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Percent", HeaderText = "Chance per pick %", FillWeight = 20 });

            grid.CellEndEdit += (s, e) =>
            {
                DetachPercentEditBox();
                OnCellEdited(e.RowIndex, e.ColumnIndex);
            };

            // Keep the total up to date while a chance is being typed, not only after Enter.
            grid.EditingControlShowing += (s, e) =>
            {
                DetachPercentEditBox();
                if (grid.CurrentCell != null && grid.Columns[grid.CurrentCell.ColumnIndex].Name == "Percent" && e.Control is TextBox box)
                {
                    percentEditBox = box;
                    percentEditBox.TextChanged += OnPercentTyping;
                }
            };
        }

        private void DetachPercentEditBox()
        {
            if (percentEditBox != null)
                percentEditBox.TextChanged -= OnPercentTyping;
            percentEditBox = null;
        }

        private void OnPercentTyping(object sender, EventArgs e)
        {
            if (!loadingGrid)
                UpdateTotal();
        }

        private void BuildFixedGrid()
        {
            fixedGrid.AllowUserToAddRows = false;
            fixedGrid.AllowUserToDeleteRows = false;
            fixedGrid.RowHeadersVisible = false;
            fixedGrid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            fixedGrid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            fixedGrid.Visible = false;

            fixedGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Situation", HeaderText = "When (emote)", FillWeight = 30, ReadOnly = true });
            fixedGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Wcid", HeaderText = "WCID", FillWeight = 15 });
            fixedGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "ItemName", HeaderText = "Item", FillWeight = 40, ReadOnly = true });
            fixedGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Stack", HeaderText = "Stack (-1 = default)", FillWeight = 15 });

            fixedGrid.CellEndEdit += (s, e) =>
            {
                if (loadingGrid || e.RowIndex < 0)
                    return;
                dirty = true;
                var row = fixedGrid.Rows[e.RowIndex];
                if (fixedGrid.Columns[e.ColumnIndex].Name == "Wcid")
                {
                    var text = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                    row.Cells["ItemName"].Value = uint.TryParse(text, out var wcid)
                        ? index.GetName(wcid) ?? "(not found in Content - check the WCID)"
                        : "(invalid WCID)";
                }
                UpdateTotal();
            };
        }

        private void BuildProfileGrid()
        {
            profileGrid.AllowUserToAddRows = false;
            profileGrid.AllowUserToDeleteRows = false;
            profileGrid.RowHeadersVisible = false;
            profileGrid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            profileGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Setting", HeaderText = "Setting", FillWeight = 25, ReadOnly = true });
            profileGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Value", HeaderText = "Value", FillWeight = 12 });
            profileGrid.Columns.Add(new DataGridViewTextBoxColumn { Name = "Help", HeaderText = "What it does", FillWeight = 63, ReadOnly = true });
            profileGrid.CellEndEdit += (s, e) =>
            {
                if (loadingGrid)
                    return;
                dirty = true;
                UpdateTotal();
            };
        }

        // ---------- repo / settings ----------

        private static string LoadSavedRepo()
        {
            try { return File.Exists(SettingsPath) ? File.ReadAllText(SettingsPath).Trim() : null; }
            catch { return null; }
        }

        private void SaveRepoSetting()
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(SettingsPath));
                File.WriteAllText(SettingsPath, RepoRoot);
            }
            catch { /* not important */ }
        }

        /// <summary>Walks up from the exe's folder looking for the repo (a folder containing Content\sql).</summary>
        private static string FindRepoFromExe()
        {
            var dir = new DirectoryInfo(AppContext.BaseDirectory);
            while (dir != null)
            {
                if (Directory.Exists(Path.Combine(dir.FullName, "Content", "sql")))
                    return dir.FullName;
                dir = dir.Parent;
            }
            return null;
        }

        private void BrowseRepo()
        {
            using (var dialog = new FolderBrowserDialog { Description = "Select the JawnTide repo folder (the one containing Content)" })
            {
                if (dialog.ShowDialog(this) == DialogResult.OK)
                {
                    repoBox.Text = dialog.SelectedPath;
                    LoadRepo();
                }
            }
        }

        private void LoadRepo()
        {
            if (!ConfirmDiscard() || !ConfirmVendorDiscard())
                return;

            if (!Directory.Exists(ContentSql))
            {
                MessageBox.Show(this, "That folder doesn't contain Content\\sql. Pick the JawnTide repo folder.", "Loot Editor");
                return;
            }

            SaveRepoSetting();
            Cursor = Cursors.WaitCursor;
            try
            {
                var found = new List<Entry>();
                var vendors = new List<VendorEntry>();
                index.Build(ContentSql,
                    path => found.Add(new Entry { Path = path }),
                    (path, tables) => found.AddRange(tables.Select(tb => new Entry { Path = path, TableName = tb })),
                    path => found.Add(new Entry { Path = path, IsProfile = true }),
                    path => vendors.Add(new VendorEntry { Path = path }));

                foreach (var entry in found)
                {
                    if (entry.IsProfile)
                    {
                        var tt = LootProfileFile.ReadTreasureType(File.ReadAllText(entry.Path));
                        entry.Label = $"{tt}  {Path.GetFileNameWithoutExtension(entry.Path)}";
                        continue;
                    }

                    var text = File.ReadAllText(entry.Path);
                    var header = ChestFile.ReadWeenieHeader(text);
                    var name = ChestFile.ReadName(text) ?? Path.GetFileNameWithoutExtension(entry.Path);
                    entry.Label = entry.IsChest || entry.IsBox
                        ? $"{name}  ({header?.wcid})"
                        : $"{name} - {entry.TableName}  ({header?.wcid})";
                }
                found.Sort((a, b) => string.Compare(a.Label, b.Label, StringComparison.OrdinalIgnoreCase));

                entries.Clear();
                entries.AddRange(found);
                suppressSelect = true;
                foreach (var list in new[] { chestList, npcList, boxList, profileList })
                    list.Items.Clear();
                foreach (var entry in found)
                {
                    var list = entry.IsProfile ? profileList : entry.IsChest ? chestList : entry.IsBox ? boxList : npcList;
                    list.Items.Add(entry);
                }
                suppressSelect = false;
                lootTabs.TabPages[0].Text = $"Chests ({chestList.Items.Count})";
                lootTabs.TabPages[1].Text = $"NPC rewards ({npcList.Items.Count})";
                lootTabs.TabPages[2].Text = $"Boxes ({boxList.Items.Count})";
                lootTabs.TabPages[3].Text = $"Loot profiles ({profileList.Items.Count})";

                foreach (var vendor in vendors)
                {
                    var text = File.ReadAllText(vendor.Path);
                    var header = ChestFile.ReadWeenieHeader(text);
                    vendor.Wcid = header?.wcid ?? 0;
                    vendor.Label = $"{ChestFile.ReadName(text) ?? Path.GetFileNameWithoutExtension(vendor.Path)}  ({header?.wcid})";
                }
                vendors.Sort((a, b) => string.Compare(a.Label, b.Label, StringComparison.OrdinalIgnoreCase));

                // stock vendors (read-only reference copies in Ops/stock-vendors)
                var stock = new List<VendorEntry>();
                if (Directory.Exists(StockVendorsRoot))
                {
                    var contentWcids = new HashSet<uint>(vendors.Select(v => v.Wcid));
                    foreach (var file in Directory.GetFiles(StockVendorsRoot, "*.sql"))
                    {
                        var text = File.ReadAllText(file);
                        var header = ChestFile.ReadWeenieHeader(text);
                        if (header == null || !VendorFile.IsVendor(text))
                            continue;
                        var inContent = contentWcids.Contains(header.Value.wcid);
                        stock.Add(new VendorEntry
                        {
                            Path = file,
                            Wcid = header.Value.wcid,
                            IsStock = true,
                            InContent = inContent,
                            Label = $"{ChestFile.ReadName(text) ?? Path.GetFileNameWithoutExtension(file)}  ({header.Value.wcid})" + (inContent ? "  - in Content" : ""),
                        });
                    }
                    stock.Sort((a, b) => string.Compare(a.Label, b.Label, StringComparison.OrdinalIgnoreCase));
                }

                suppressSelect = true;
                vendorList.Items.Clear();
                foreach (var vendor in vendors)
                    vendorList.Items.Add(vendor);
                stockVendorList.Items.Clear();
                foreach (var vendor in stock)
                    stockVendorList.Items.Add(vendor);
                suppressSelect = false;
                vendorTabs.TabPages[0].Text = $"JawnTide vendors ({vendors.Count})";
                vendorTabs.TabPages[1].Text = $"Stock vendors ({stock.Count})";
                mainTabs.TabPages[1].Text = $"Vendors ({vendors.Count} + {stock.Count} stock)";

                selectedEntry = null;
                selectedVendor = null;
                RefreshTargets(LiveTarget);
                ClearChest();
                ClearVendor();
            }
            finally
            {
                Cursor = Cursors.Default;
            }
        }

        private void RefreshTargets(string select)
        {
            targetBox.Items.Clear();
            targetBox.Items.Add(LiveTarget);
            if (Directory.Exists(StagesRoot))
            {
                foreach (var dir in Directory.GetDirectories(StagesRoot).OrderBy(d => d))
                    targetBox.Items.Add(Path.GetFileName(dir));
            }
            targetBox.SelectedItem = targetBox.Items.Contains(select) ? select : LiveTarget;
        }

        private void CreateStage()
        {
            var name = Prompt("New stage folder name (for example: stage2)", "stage2");
            if (string.IsNullOrWhiteSpace(name))
                return;
            name = name.Trim();
            if (name.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
            {
                MessageBox.Show(this, "That name has characters that can't be used in a folder name.", "Loot Editor");
                return;
            }
            Directory.CreateDirectory(Path.Combine(StagesRoot, name));
            RefreshTargets(name);
        }

        // ---------- chest loading ----------

        private string TargetPathFor(string contentPath)
        {
            var target = targetBox.SelectedItem as string;
            if (target == null || target == LiveTarget)
                return contentPath;
            var relative = Path.GetRelativePath(ContentSql, contentPath);
            return Path.Combine(StagesRoot, target, relative);
        }

        private void OnTargetChanged()
        {
            if (targetBox.SelectedItem == lastTarget)
                return;
            if (!ConfirmDiscard() || !ConfirmVendorDiscard())
            {
                targetBox.SelectedItem = lastTarget;
                return;
            }
            lastTarget = targetBox.SelectedItem;
            LoadSelectedChest();
            LoadSelectedVendor();
        }

        private void OnListSelected(ListBox list)
        {
            if (suppressSelect || list.SelectedIndex < 0)
                return;
            var entry = (Entry)list.SelectedItem;
            if (entry == selectedEntry)
                return;

            suppressSelect = true;
            try
            {
                if (!ConfirmDiscard())
                {
                    // put the selection back on the open item (it may be on another tab)
                    list.ClearSelected();
                    if (selectedEntry != null && list.Items.Contains(selectedEntry))
                        list.SelectedItem = selectedEntry;
                    return;
                }
                // only one item is open at a time: clear the selection on the other tabs
                foreach (var other in new[] { chestList, npcList, boxList, profileList })
                    if (other != list)
                        other.ClearSelected();
            }
            finally
            {
                suppressSelect = false;
            }

            selectedEntry = entry;
            LoadSelectedChest();
        }

        private void LoadSelectedChest()
        {
            if (selectedEntry == null)
            {
                ClearChest();
                return;
            }

            var entry = selectedEntry;
            var contentPath = entry.Path;
            var targetPath = TargetPathFor(contentPath);
            var loadPath = File.Exists(targetPath) ? targetPath : contentPath;

            try
            {
                current = null;
                currentRewards = null;
                currentProfile = null;
                if (entry.IsProfile)
                    currentProfile = LootProfileFile.Load(loadPath);
                else if (entry.IsChest)
                    current = ChestFile.Load(loadPath, index);
                else
                    currentRewards = EmoteRewardFile.Load(loadPath, entry.TableName, index);
            }
            catch (Exception ex)
            {
                ClearChest();
                MessageBox.Show(this, "Couldn't read this file:\n" + ex.Message, "Loot Editor");
                return;
            }

            SetProfileMode(currentProfile != null);

            if (currentProfile != null)
            {
                ShowProfile(loadPath, targetPath);
                return;
            }

            if (currentRewards != null)
            {
                ShowRewards(loadPath, targetPath);
                return;
            }

            fixedGrid.Visible = false;
            alwaysList.Visible = true;
            alwaysLabel.Text = "Always generated (not editable here)";
            gridLabel.Text = "Random pick items (one pick = one roll; the chest makes several picks)";

            var target = targetBox.SelectedItem as string ?? LiveTarget;
            var source = loadPath == targetPath
                ? (target == LiveTarget ? "Content" : "stage " + target)
                : "Content (no " + target + " version yet; saving creates one)";
            var picks = current.InitGeneratedObjects.HasValue ? $"{current.InitGeneratedObjects} picks when it fills (max {current.MaxGeneratedObjects})" : "picks: unknown";

            chestInfo.Text = $"{current.Name}  (WCID {current.ChestWcid})   -   {picks}\nLoaded from: {source}\n{loadPath}";

            alwaysList.Items.Clear();
            foreach (var row in current.AlwaysRows)
            {
                var what = row.IsTreasureProfile
                    ? $"Random loot from loot profile {row.Wcid}"
                    : $"{index.GetName(row.Wcid) ?? WeenieIndex.NameFromComment(row.Comment) ?? "(unknown)"} ({row.Wcid})";
                alwaysList.Items.Add("Always: " + what);
            }
            if (current.AlwaysRows.Count == 0)
                alwaysList.Items.Add("(nothing)");

            loadingGrid = true;
            grid.Rows.Clear();
            foreach (var pick in current.Picks)
            {
                var i = grid.Rows.Add(pick.Wcid.ToString(), pick.Name, pick.StackSize.ToString(), pick.Percent.ToString("0.###", CultureInfo.InvariantCulture));
                grid.Rows[i].Tag = pick.Original;
            }
            loadingGrid = false;

            dirty = false;
            UpdateTotal();
        }

        private string SourceText(string loadPath, string targetPath)
        {
            var target = targetBox.SelectedItem as string ?? LiveTarget;
            return loadPath == targetPath
                ? (target == LiveTarget ? "Content" : "stage " + target)
                : "Content (no " + target + " version yet; saving creates one)";
        }

        /// <summary>Loot profiles use their own settings grid; chests and NPC tables use the item grids.</summary>
        private void SetProfileMode(bool profile)
        {
            profileGrid.Visible = profile;
            grid.Visible = !profile;
            addButton.Enabled = !profile;
            removeButton.Enabled = !profile;
            scaleButton.Enabled = !profile;
            if (profile)
                fixedGrid.Visible = false;
        }

        private void ShowProfile(string loadPath, string targetPath)
        {
            var users = index.GetProfileUsers(currentProfile.TreasureType);
            chestInfo.Text = $"Loot profile {currentProfile.TreasureType}   -   used by {users.Count} monster(s)/container(s) in Content\nLoaded from: {SourceText(loadPath, targetPath)}\n{loadPath}";

            alwaysLabel.Text = "Used by (monsters and containers in Content that roll this profile)";
            gridLabel.Text = "Loot profile settings (random loot only; loot_max_tier still caps the tier on the server)";
            alwaysList.Visible = true;
            alwaysList.Items.Clear();
            foreach (var user in users)
                alwaysList.Items.Add(user);
            if (users.Count == 0)
                alwaysList.Items.Add("(nothing in Content uses it - stock monsters may still use it)");

            loadingGrid = true;
            profileGrid.Rows.Clear();
            foreach (var field in currentProfile.Fields)
            {
                var i = profileGrid.Rows.Add(field.Label, field.Value, field.Help);
                profileGrid.Rows[i].Tag = field;
            }
            loadingGrid = false;

            dirty = false;
            UpdateTotal();
        }

        private void ShowRewards(string loadPath, string targetPath)
        {
            chestInfo.Text = currentRewards.IsUseTable
                ? $"{currentRewards.Name}  (WCID {currentRewards.Wcid})   -   gives one of these when used (one roll). The \"You found ...\" message is rewritten for new items and changed stacks.\nLoaded from: {SourceText(loadPath, targetPath)}\n{loadPath}"
                : $"{currentRewards.Name}  (WCID {currentRewards.Wcid})   -   random reward table \"{currentRewards.TableName}\" (one roll each time it runs)\nLoaded from: {SourceText(loadPath, targetPath)}\n{loadPath}";

            alwaysList.Visible = false;
            fixedGrid.Visible = true;
            alwaysLabel.Text = currentRewards.IsUseTable
                ? "Fixed rewards elsewhere in this item's script (always given; edit WCID or stack)"
                : "Fixed rewards elsewhere in this NPC's script (always given; edit WCID or stack)";
            gridLabel.Text = currentRewards.IsUseTable
                ? "Contents (one roll each time it is used; chances must add up to 100%)"
                : "Random reward table (one roll; chances must add up to 100%)";

            loadingGrid = true;
            fixedGrid.Rows.Clear();
            foreach (var give in currentRewards.FixedGives)
            {
                var i = fixedGrid.Rows.Add(give.Situation, give.Wcid.ToString(), give.Name, give.StackSize.ToString());
                fixedGrid.Rows[i].Tag = give;
            }

            grid.Rows.Clear();
            foreach (var pick in currentRewards.Picks)
            {
                var i = grid.Rows.Add(pick.Wcid.ToString(), pick.Name, pick.StackSize.ToString(), pick.Percent.ToString("0.###", CultureInfo.InvariantCulture));
                grid.Rows[i].Tag = pick;   // remembers which set the row came from (cleared when its WCID changes)
            }
            loadingGrid = false;

            dirty = false;
            UpdateTotal();
        }

        private void ClearChest()
        {
            current = null;
            currentRewards = null;
            currentProfile = null;
            SetProfileMode(false);
            dirty = false;
            chestInfo.Text = "Select a chest, NPC table, box or loot profile on the left.";
            alwaysList.Items.Clear();
            loadingGrid = true;
            grid.Rows.Clear();
            fixedGrid.Rows.Clear();
            profileGrid.Rows.Clear();
            loadingGrid = false;
            UpdateTotal();
        }

        // ---------- editing ----------

        private void OnCellEdited(int rowIndex, int columnIndex)
        {
            if (loadingGrid || rowIndex < 0)
                return;
            dirty = true;

            var row = grid.Rows[rowIndex];
            if (grid.Columns[columnIndex].Name == "Wcid")
            {
                var text = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                row.Cells["ItemName"].Value = uint.TryParse(text, out var wcid)
                    ? index.GetName(wcid) ?? "(not found in Content - check the WCID)"
                    : "(invalid WCID)";
                // a different item is no longer the original row
                row.Tag = null;
            }
            UpdateTotal();
        }

        private bool HasOpenFile => current != null || currentRewards != null || currentProfile != null;

        private void AddItem()
        {
            if (!HasOpenFile)
                return;
            var i = grid.Rows.Add("", "(type a WCID)", "-1", "0");
            grid.Rows[i].Tag = null;
            grid.CurrentCell = grid.Rows[i].Cells["Wcid"];
            grid.BeginEdit(true);
            dirty = true;
            UpdateTotal();
        }

        private void RemoveSelected()
        {
            if (!HasOpenFile)
                return;
            foreach (var row in grid.SelectedRows.Cast<DataGridViewRow>().ToList())
                grid.Rows.Remove(row);
            dirty = true;
            UpdateTotal();
        }

        private double TotalPercent()
        {
            double total = 0;
            foreach (DataGridViewRow row in grid.Rows)
            {
                // While a chance is being typed, count what is in the edit box rather than the old value.
                var text = percentEditBox != null && grid.IsCurrentCellInEditMode && grid.CurrentCell != null
                           && grid.CurrentCell.RowIndex == row.Index && grid.Columns[grid.CurrentCell.ColumnIndex].Name == "Percent"
                    ? percentEditBox.Text
                    : (row.Cells["Percent"].Value ?? "").ToString();
                if (double.TryParse(text.Trim(), NumberStyles.Float, CultureInfo.InvariantCulture, out var p))
                    total += p;
            }
            return total;
        }

        /// <summary>
        /// Multiplies every chance by the same factor so the list adds up to exactly 100%,
        /// keeping the items' chances in the same proportion to each other.
        /// </summary>
        private void ScaleTo100()
        {
            if (!HasOpenFile || currentProfile != null || grid.Rows.Count == 0)
                return;
            grid.EndEdit();

            var values = new List<(DataGridViewRow row, double pct)>();
            foreach (DataGridViewRow row in grid.Rows)
            {
                if (!double.TryParse((row.Cells["Percent"].Value ?? "").ToString().Trim(), NumberStyles.Float, CultureInfo.InvariantCulture, out var p) || p <= 0)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: the chance must be a number above 0 before scaling.", "Loot Editor");
                    return;
                }
                values.Add((row, p));
            }

            var total = values.Sum(v => v.pct);
            if (Math.Abs(total - 100) < 0.0005)
                return;

            var answer = MessageBox.Show(this,
                $"The chances add up to {total.ToString("0.###", CultureInfo.InvariantCulture)}%.\n\n" +
                $"Multiply every chance by {(100 / total).ToString("0.###", CultureInfo.InvariantCulture)} so they add up to 100%?\n" +
                "Every item keeps the same share of the total.",
                "Loot Editor", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (answer != DialogResult.Yes)
                return;

            // Round to 3 decimals; the largest row absorbs the rounding so the sum is exactly 100.
            var scaled = values.Select(v => Math.Round(v.pct * 100 / total, 3)).ToArray();
            var largest = Array.IndexOf(scaled, scaled.Max());
            scaled[largest] = Math.Round(scaled[largest] + (100 - scaled.Sum()), 3);

            for (var i = 0; i < values.Count; i++)
                values[i].row.Cells["Percent"].Value = scaled[i].ToString("0.###", CultureInfo.InvariantCulture);

            dirty = true;
            UpdateTotal();
        }

        private void UpdateTotal()
        {
            if (!HasOpenFile)
            {
                totalLabel.Text = "";
                return;
            }
            if (currentProfile != null)
            {
                totalLabel.Text = dirty ? "* unsaved" : "";
                totalLabel.ForeColor = SystemColors.ControlText;
                return;
            }
            var total = TotalPercent();
            var ok = grid.Rows.Count == 0 || Math.Abs(total - 100) < 0.01;
            var gap = 100 - total;
            var hint = ok ? ""
                : gap > 0 ? $"  (must be 100%: add {gap.ToString("0.###", CultureInfo.InvariantCulture)}%)"
                : $"  (must be 100%: remove {(-gap).ToString("0.###", CultureInfo.InvariantCulture)}%)";
            totalLabel.Text = $"Total: {total.ToString("0.###", CultureInfo.InvariantCulture)}%" + hint + (dirty ? "   * unsaved" : "");
            totalLabel.ForeColor = ok ? SystemColors.ControlText : Color.Firebrick;
        }

        private void Save()
        {
            if (!HasOpenFile)
                return;

            grid.EndEdit();
            fixedGrid.EndEdit();
            profileGrid.EndEdit();

            if (currentProfile != null)
            {
                SaveProfile();
                return;
            }
            var picks = new List<PickItem>();
            foreach (DataGridViewRow row in grid.Rows)
            {
                var wcidText = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                var stackText = (row.Cells["Stack"].Value ?? "").ToString().Trim();
                var pctText = (row.Cells["Percent"].Value ?? "").ToString().Trim();

                if (!uint.TryParse(wcidText, out var wcid) || wcid == 0)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: the WCID \"{wcidText}\" isn't a valid number.", "Loot Editor");
                    return;
                }
                if (!int.TryParse(stackText, out var stack) || stack == 0 || stack < -1)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: stack must be -1 (default) or a number of 1 or more.", "Loot Editor");
                    return;
                }
                if (!double.TryParse(pctText, NumberStyles.Float, CultureInfo.InvariantCulture, out var pct) || pct <= 0)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: the chance must be a number above 0 (use a dot for decimals, like 2.5).", "Loot Editor");
                    return;
                }

                picks.Add(new PickItem
                {
                    Wcid = wcid,
                    Name = index.GetName(wcid) ?? (row.Cells["ItemName"].Value ?? "").ToString(),
                    StackSize = stack,
                    Percent = pct,
                    Original = row.Tag as GeneratorRow,
                    SourceBlock = (row.Tag as PickItem)?.SourceBlock ?? -1,
                    SourceStack = (row.Tag as PickItem)?.SourceStack ?? -1,
                });
            }

            if (picks.Count > 0 && Math.Abs(TotalPercent() - 100) >= 0.01)
            {
                MessageBox.Show(this, "The chances must add up to exactly 100% before saving.", "Loot Editor");
                return;
            }

            var targetPath = TargetPathFor(selectedEntry.Path);

            var fixedGives = new List<FixedGive>();
            foreach (DataGridViewRow row in fixedGrid.Rows)
            {
                var give = row.Tag as FixedGive;
                if (give == null)
                    continue;
                var wcidText = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                var stackText = (row.Cells["Stack"].Value ?? "").ToString().Trim();
                if (!uint.TryParse(wcidText, out var wcid) || wcid == 0)
                {
                    MessageBox.Show(this, $"Fixed reward row {row.Index + 1}: the WCID \"{wcidText}\" isn't a valid number.", "Loot Editor");
                    return;
                }
                if (!int.TryParse(stackText, out var stack) || stack == 0 || stack < -1)
                {
                    MessageBox.Show(this, $"Fixed reward row {row.Index + 1}: stack must be -1 (default) or a number of 1 or more.", "Loot Editor");
                    return;
                }
                give.Wcid = wcid;
                give.StackSize = stack;
                give.Name = index.GetName(wcid) ?? (row.Cells["ItemName"].Value ?? "").ToString();
                fixedGives.Add(give);
            }

            if (currentRewards != null && picks.Count == 0)
            {
                MessageBox.Show(this, "A reward table needs at least one item.", "Loot Editor");
                return;
            }

            try
            {
                if (current != null)
                    current.Save(targetPath, picks);
                else
                    currentRewards.Save(targetPath, picks, fixedGives);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "Save failed:\n" + ex.Message, "Loot Editor");
                return;
            }

            dirty = false;
            LoadSelectedChest();
            MessageBox.Show(this, "Saved to:\n" + targetPath, "Loot Editor");
        }

        private void SaveProfile()
        {
            var fields = new List<ProfileField>();
            foreach (DataGridViewRow row in profileGrid.Rows)
            {
                var field = row.Tag as ProfileField;
                if (field == null)
                    continue;
                fields.Add(new ProfileField
                {
                    Column = field.Column,
                    Label = field.Label,
                    Help = field.Help,
                    IsInteger = field.IsInteger,
                    Value = (row.Cells["Value"].Value ?? "").ToString().Trim(),
                });
            }

            var error = LootProfileFile.Validate(fields);
            if (error != null)
            {
                MessageBox.Show(this, error, "Loot Editor");
                return;
            }

            var targetPath = TargetPathFor(selectedEntry.Path);
            try
            {
                currentProfile.Save(targetPath, fields);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "Save failed:\n" + ex.Message, "Loot Editor");
                return;
            }

            dirty = false;
            LoadSelectedChest();
            MessageBox.Show(this, "Saved to:\n" + targetPath, "Loot Editor");
        }

        private bool ConfirmDiscard()
        {
            if (!dirty)
                return true;
            var answer = MessageBox.Show(this, "You have unsaved changes to this chest. Discard them?", "Loot Editor", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (answer == DialogResult.Yes)
            {
                dirty = false;
                return true;
            }
            return false;
        }

        // ---------- vendors ----------

        private void OnVendorSelected(ListBox list)
        {
            if (suppressSelect || list.SelectedIndex < 0)
                return;
            var vendor = (VendorEntry)list.SelectedItem;
            if (vendor == selectedVendor)
                return;

            suppressSelect = true;
            try
            {
                if (!ConfirmVendorDiscard())
                {
                    list.ClearSelected();
                    if (selectedVendor != null && list.Items.Contains(selectedVendor))
                        list.SelectedItem = selectedVendor;
                    return;
                }
                var other = list == vendorList ? stockVendorList : vendorList;
                other.ClearSelected();
            }
            finally
            {
                suppressSelect = false;
            }

            selectedVendor = vendor;
            LoadSelectedVendor();
        }

        /// <summary>Copies the selected stock vendor into Content/sql/weenies/Stock Vendors so it can be edited.</summary>
        private void CopyStockVendor()
        {
            var stock = selectedVendor;
            if (stock == null || !stock.IsStock)
                return;
            if (stock.InContent)
            {
                MessageBox.Show(this, "This vendor already has a file in Content. Edit it on the JawnTide vendors tab.", "Loot Editor");
                return;
            }

            var target = Path.Combine(StockVendorsTarget, Path.GetFileName(stock.Path));
            var answer = MessageBox.Show(this,
                $"Copy {stock.Label} into Content so it can be edited?\n\n{target}\n\n" +
                "From then on this file overrides the stock vendor when Content is imported. " +
                "Commit it, test on JawnTest and merge it like any other Content change.",
                "Loot Editor", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (answer != DialogResult.Yes)
                return;

            try
            {
                Directory.CreateDirectory(StockVendorsTarget);
                File.Copy(stock.Path, target, false);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "Copy failed:\n" + ex.Message, "Loot Editor");
                return;
            }

            // rescan, then open the new copy on the JawnTide vendors tab
            LoadRepo();
            foreach (VendorEntry vendor in vendorList.Items)
            {
                if (string.Equals(Path.GetFullPath(vendor.Path), Path.GetFullPath(target), StringComparison.OrdinalIgnoreCase))
                {
                    mainTabs.SelectedIndex = 1;
                    vendorTabs.SelectedIndex = 0;
                    vendorList.SelectedItem = vendor;
                    break;
                }
            }
        }

        private void LoadSelectedVendor()
        {
            if (selectedVendor == null)
            {
                ClearVendor();
                return;
            }

            var isStock = selectedVendor.IsStock;
            var targetPath = isStock ? selectedVendor.Path : TargetPathFor(selectedVendor.Path);
            var loadPath = File.Exists(targetPath) ? targetPath : selectedVendor.Path;
            try
            {
                currentVendor = VendorFile.Load(loadPath, index);
            }
            catch (Exception ex)
            {
                ClearVendor();
                MessageBox.Show(this, "Couldn't read this vendor:\n" + ex.Message, "Loot Editor");
                return;
            }

            vendorInfo.Text = isStock
                ? $"{currentVendor.Name}  (WCID {currentVendor.Wcid})   -   {currentVendor.Items.Count} items for sale   -   STOCK (read-only)" +
                  (selectedVendor.InContent ? "\nThis vendor already has a file in Content: edit it on the JawnTide vendors tab." : "\nTo change it, use \"Copy into Content to edit\".") + $"\n{loadPath}"
                : $"{currentVendor.Name}  (WCID {currentVendor.Wcid})   -   {currentVendor.Items.Count} items for sale\nLoaded from: {SourceText(loadPath, targetPath)}\n{loadPath}";
            vendorGrid.ReadOnly = isStock;
            vendorAddButton.Enabled = !isStock;
            vendorRemoveButton.Enabled = !isStock;
            vendorSaveButton.Enabled = !isStock;
            copyStockButton.Visible = isStock;
            copyStockButton.Enabled = isStock && !selectedVendor.InContent;
            vendorLoading = true;
            vendorGrid.Rows.Clear();
            foreach (var item in currentVendor.Items)
            {
                var i = vendorGrid.Rows.Add(item.Wcid.ToString(), item.Name, item.StackSize.ToString(CultureInfo.InvariantCulture));
                vendorGrid.Rows[i].Tag = item;
            }
            vendorLoading = false;
            vendorDirty = false;
            UpdateVendorCount();
        }

        private void ClearVendor()
        {
            currentVendor = null;
            vendorDirty = false;
            vendorInfo.Text = "Select a vendor on the left.";
            vendorGrid.ReadOnly = false;
            vendorAddButton.Enabled = true;
            vendorRemoveButton.Enabled = true;
            vendorSaveButton.Enabled = true;
            copyStockButton.Visible = false;
            vendorLoading = true;
            vendorGrid.Rows.Clear();
            vendorLoading = false;
            UpdateVendorCount();
        }

        private void UpdateVendorCount()
        {
            vendorCountLabel.Text = currentVendor == null ? "" : $"{vendorGrid.Rows.Count} items" + (vendorDirty ? "   * unsaved" : "");
        }

        private void AddVendorItem()
        {
            if (currentVendor == null || selectedVendor == null || selectedVendor.IsStock)
                return;
            var i = vendorGrid.Rows.Add("", "(type a WCID)", "-1");
            vendorGrid.Rows[i].Tag = null;
            vendorGrid.CurrentCell = vendorGrid.Rows[i].Cells["Wcid"];
            vendorGrid.BeginEdit(true);
            vendorDirty = true;
            UpdateVendorCount();
        }

        private void RemoveVendorItems()
        {
            if (currentVendor == null || selectedVendor == null || selectedVendor.IsStock)
                return;
            foreach (var row in vendorGrid.SelectedRows.Cast<DataGridViewRow>().ToList())
                vendorGrid.Rows.Remove(row);
            vendorDirty = true;
            UpdateVendorCount();
        }

        private void SaveVendor()
        {
            if (currentVendor == null || selectedVendor == null || selectedVendor.IsStock)
                return;
            vendorGrid.EndEdit();

            var items = new List<VendorItem>();
            foreach (DataGridViewRow row in vendorGrid.Rows)
            {
                var wcidText = (row.Cells["Wcid"].Value ?? "").ToString().Trim();
                var stackText = (row.Cells["Stack"].Value ?? "").ToString().Trim();
                if (!uint.TryParse(wcidText, out var wcid) || wcid == 0)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: the WCID \"{wcidText}\" isn't a valid number.", "Loot Editor");
                    return;
                }
                if (!int.TryParse(stackText, out var stack) || stack < -1)
                {
                    MessageBox.Show(this, $"Row {row.Index + 1}: supply must be -1 (unlimited) or 0 or more.", "Loot Editor");
                    return;
                }
                var original = row.Tag as VendorItem;
                items.Add(new VendorItem
                {
                    Wcid = wcid,
                    Name = index.GetName(wcid) ?? (row.Cells["ItemName"].Value ?? "").ToString(),
                    StackSize = stack,
                    Tokens = original?.Tokens,
                    Comment = original?.Comment,
                });
            }

            var targetPath = TargetPathFor(selectedVendor.Path);
            try
            {
                currentVendor.Save(targetPath, items);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, "Save failed:\n" + ex.Message, "Loot Editor");
                return;
            }

            vendorDirty = false;
            LoadSelectedVendor();
            MessageBox.Show(this, "Saved to:\n" + targetPath, "Loot Editor");
        }

        private bool ConfirmVendorDiscard()
        {
            if (!vendorDirty)
                return true;
            var answer = MessageBox.Show(this, "You have unsaved changes to this vendor. Discard them?", "Loot Editor", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (answer == DialogResult.Yes)
            {
                vendorDirty = false;
                return true;
            }
            return false;
        }

        private string Prompt(string message, string defaultValue)
        {
            using (var form = new Form { Text = "Loot Editor", Width = 420, Height = 150, FormBorderStyle = FormBorderStyle.FixedDialog, StartPosition = FormStartPosition.CenterParent, MinimizeBox = false, MaximizeBox = false })
            {
                var label = new Label { Text = message, Left = 12, Top = 12, Width = 380 };
                var box = new TextBox { Text = defaultValue, Left = 12, Top = 36, Width = 380 };
                var ok = new Button { Text = "OK", Left = 236, Top = 70, Width = 75, DialogResult = DialogResult.OK };
                var cancel = new Button { Text = "Cancel", Left = 317, Top = 70, Width = 75, DialogResult = DialogResult.Cancel };
                form.Controls.AddRange(new Control[] { label, box, ok, cancel });
                form.AcceptButton = ok;
                form.CancelButton = cancel;
                return form.ShowDialog(this) == DialogResult.OK ? box.Text : null;
            }
        }
    }
}
