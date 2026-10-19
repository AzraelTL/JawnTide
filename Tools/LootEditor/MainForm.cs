using System.Globalization;

namespace LootEditor
{
    public class MainForm : Form
    {
        private const string LiveTarget = "Content (current stage)";

        private readonly TextBox repoBox = new TextBox { Dock = DockStyle.Fill };
        private readonly Button browseButton = new Button { Text = "Browse...", AutoSize = true };
        private readonly Button reloadButton = new Button { Text = "Reload", AutoSize = true };
        private readonly ComboBox targetBox = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Width = 220 };
        private readonly Button newStageButton = new Button { Text = "New stage...", AutoSize = true };

        private readonly ListBox chestList = new ListBox { Dock = DockStyle.Fill, IntegralHeight = false };
        private readonly Label chestInfo = new Label { Dock = DockStyle.Top, AutoSize = false, Height = 54 };
        private readonly ListBox alwaysList = new ListBox { Dock = DockStyle.Top, Height = 70, IntegralHeight = false };
        private readonly DataGridView grid = new DataGridView { Dock = DockStyle.Fill };
        private readonly Label totalLabel = new Label { AutoSize = true, Padding = new Padding(0, 7, 12, 0) };
        private readonly Button addButton = new Button { Text = "Add item", AutoSize = true };
        private readonly Button removeButton = new Button { Text = "Remove selected", AutoSize = true };
        private readonly Button saveButton = new Button { Text = "Save", AutoSize = true };

        private readonly WeenieIndex index = new WeenieIndex();
        private readonly List<string> chestPaths = new List<string>();
        private ChestFile current;
        private bool dirty;
        private bool loadingGrid;
        private int lastChestIndex = -1;
        private object lastTarget;
        private SplitContainer split;

        private static string SettingsPath => Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "JawnTideLootEditor", "settings.txt");

        private string RepoRoot => repoBox.Text.Trim();
        private string ContentSql => Path.Combine(RepoRoot, "Content", "sql");
        private string StagesRoot => Path.Combine(RepoRoot, "Ops", "loot-stages");

        public MainForm()
        {
            Text = "JawnTide Loot Editor - Chests";
            Width = 1150;
            Height = 720;
            StartPosition = FormStartPosition.CenterScreen;

            BuildLayout();
            BuildGrid();

            browseButton.Click += (s, e) => BrowseRepo();
            reloadButton.Click += (s, e) => LoadRepo();
            newStageButton.Click += (s, e) => CreateStage();
            targetBox.SelectedIndexChanged += (s, e) => OnTargetChanged();
            chestList.SelectedIndexChanged += (s, e) => OnChestSelected();
            addButton.Click += (s, e) => AddItem();
            removeButton.Click += (s, e) => RemoveSelected();
            saveButton.Click += (s, e) => Save();
            FormClosing += (s, e) => { if (!ConfirmDiscard()) e.Cancel = true; };

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
            Load += (s, e) => split.SplitterDistance = 300;
            var leftLabel = new Label { Text = "Chests", Dock = DockStyle.Top, Height = 20, Font = new Font(Font, FontStyle.Bold) };
            split.Panel1.Controls.Add(chestList);
            split.Panel1.Controls.Add(leftLabel);
            split.Panel1.Padding = new Padding(6);

            var bottom = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 38, FlowDirection = FlowDirection.LeftToRight, Padding = new Padding(0, 4, 0, 0) };
            bottom.Controls.Add(totalLabel);
            bottom.Controls.Add(addButton);
            bottom.Controls.Add(removeButton);
            bottom.Controls.Add(saveButton);

            var gridLabel = new Label { Text = "Random pick items (one pick = one roll; the chest makes several picks)", Dock = DockStyle.Top, Height = 20, Font = new Font(Font, FontStyle.Bold) };
            var alwaysLabel = new Label { Text = "Always generated (not editable here)", Dock = DockStyle.Top, Height = 20, Font = new Font(Font, FontStyle.Bold) };

            split.Panel2.Padding = new Padding(6);
            split.Panel2.Controls.Add(grid);
            split.Panel2.Controls.Add(gridLabel);
            split.Panel2.Controls.Add(alwaysList);
            split.Panel2.Controls.Add(alwaysLabel);
            split.Panel2.Controls.Add(chestInfo);
            split.Panel2.Controls.Add(bottom);

            Controls.Add(split);
            Controls.Add(top);
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

            grid.CellEndEdit += (s, e) => OnCellEdited(e.RowIndex, e.ColumnIndex);
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
            if (!ConfirmDiscard())
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
                chestPaths.Clear();
                index.Build(ContentSql, path => chestPaths.Add(path));

                var chests = new List<(string path, string label)>();
                foreach (var path in chestPaths)
                {
                    var text = File.ReadAllText(path);
                    var header = ChestFile.ReadWeenieHeader(text);
                    var name = ChestFile.ReadName(text) ?? Path.GetFileNameWithoutExtension(path);
                    chests.Add((path, $"{name}  ({header?.wcid})"));
                }
                chests.Sort((a, b) => string.Compare(a.label, b.label, StringComparison.OrdinalIgnoreCase));

                chestPaths.Clear();
                chestList.Items.Clear();
                foreach (var c in chests)
                {
                    chestPaths.Add(c.path);
                    chestList.Items.Add(c.label);
                }

                RefreshTargets(LiveTarget);
                ClearChest();
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
            if (!ConfirmDiscard())
            {
                targetBox.SelectedItem = lastTarget;
                return;
            }
            lastTarget = targetBox.SelectedItem;
            LoadSelectedChest();
        }

        private void OnChestSelected()
        {
            if (chestList.SelectedIndex == lastChestIndex)
                return;
            if (!ConfirmDiscard())
            {
                chestList.SelectedIndex = lastChestIndex;
                return;
            }
            lastChestIndex = chestList.SelectedIndex;
            LoadSelectedChest();
        }

        private void LoadSelectedChest()
        {
            if (chestList.SelectedIndex < 0)
            {
                ClearChest();
                return;
            }

            var contentPath = chestPaths[chestList.SelectedIndex];
            var targetPath = TargetPathFor(contentPath);
            var loadPath = File.Exists(targetPath) ? targetPath : contentPath;

            try
            {
                current = ChestFile.Load(loadPath, index);
            }
            catch (Exception ex)
            {
                ClearChest();
                MessageBox.Show(this, "Couldn't read this chest:\n" + ex.Message, "Loot Editor");
                return;
            }

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

        private void ClearChest()
        {
            current = null;
            dirty = false;
            lastChestIndex = chestList.SelectedIndex;
            chestInfo.Text = "Select a chest on the left.";
            alwaysList.Items.Clear();
            loadingGrid = true;
            grid.Rows.Clear();
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

        private void AddItem()
        {
            if (current == null)
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
            if (current == null)
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
                if (double.TryParse((row.Cells["Percent"].Value ?? "").ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out var p))
                    total += p;
            }
            return total;
        }

        private void UpdateTotal()
        {
            if (current == null)
            {
                totalLabel.Text = "";
                return;
            }
            var total = TotalPercent();
            var ok = grid.Rows.Count == 0 || Math.Abs(total - 100) < 0.01;
            totalLabel.Text = $"Total: {total.ToString("0.###", CultureInfo.InvariantCulture)}%" + (ok ? "" : "  (must be 100%)") + (dirty ? "   * unsaved" : "");
            totalLabel.ForeColor = ok ? SystemColors.ControlText : Color.Firebrick;
        }

        private void Save()
        {
            if (current == null)
                return;

            grid.EndEdit();
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
                });
            }

            if (picks.Count > 0 && Math.Abs(TotalPercent() - 100) >= 0.01)
            {
                MessageBox.Show(this, "The chances must add up to exactly 100% before saving.", "Loot Editor");
                return;
            }

            var targetPath = TargetPathFor(chestPaths[chestList.SelectedIndex]);
            try
            {
                current.Save(targetPath, picks);
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
