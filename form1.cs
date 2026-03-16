using System;
using System.Diagnostics;
using System.Management;
using System.IO;
using System.Windows.Forms;

namespace DiskEraserGUI
{
    public partial class Form1 : Form
    {

        Process eraseProcess;

        public Form1()
        {
            InitializeComponent();
            LoadDisks();
            LoadMethods();
        }

        private void LoadMethods()
        {
            cmbMethod.Items.Add("Zero Fill");
            cmbMethod.Items.Add("Random Fill");
            cmbMethod.Items.Add("NIST Clear");
            cmbMethod.SelectedIndex = 0;
        }

        private void LoadDisks()
        {
            cmbDisks.Items.Clear();

            var searcher = new ManagementObjectSearcher(
                "SELECT * FROM Win32_DiskDrive");

            foreach (ManagementObject disk in searcher.Get())
            {
                string model = disk["Model"].ToString();
                string size = disk["Size"].ToString();

                long gb = Convert.ToInt64(size) / 1000000000;

                cmbDisks.Items.Add(model + " (" + gb + " GB)");
            }
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            if (cmbDisks.SelectedIndex < 0)
            {
                MessageBox.Show("Select a disk first.");
                return;
            }

            var confirm = MessageBox.Show(
                "WARNING: This will erase the selected disk permanently.\nContinue?",
                "Confirm Erase",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Warning);

            if (confirm != DialogResult.Yes)
                return;

            progressBar1.Value = 0;
            txtLog.Clear();

            eraseProcess = new Process();

            eraseProcess.StartInfo.FileName = "wsl";

            eraseProcess.StartInfo.Arguments =
                "sudo bash ~/wipe_engine.sh";

            eraseProcess.StartInfo.UseShellExecute = false;
            eraseProcess.StartInfo.RedirectStandardOutput = true;
            eraseProcess.StartInfo.RedirectStandardError = true;
            eraseProcess.StartInfo.CreateNoWindow = true;

            eraseProcess.OutputDataReceived += OutputHandler;
            eraseProcess.ErrorDataReceived += OutputHandler;

            eraseProcess.Start();

            eraseProcess.BeginOutputReadLine();
            eraseProcess.BeginErrorReadLine();

            lblStatus.Text = "Erasing disk...";
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            if (eraseProcess != null && !eraseProcess.HasExited)
            {
                eraseProcess.Kill();

                lblStatus.Text = "Erase aborted.";
                txtLog.AppendText("Process stopped.\n");
            }
        }

        private void OutputHandler(object sender, DataReceivedEventArgs e)
        {
            if (e.Data == null) return;

            Invoke((MethodInvoker)delegate
            {

                txtLog.AppendText(e.Data + Environment.NewLine);

                if (e.Data.StartsWith("PROGRESS:"))
                {
                    string val = e.Data.Replace("PROGRESS:", "");

                    int progress;

                    if (int.TryParse(val, out progress))
                    {
                        progressBar1.Value = Math.Min(progress, 100);
                    }
                }

                lblStatus.Text = e.Data;

            });
        }
    }
}
