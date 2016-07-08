using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using MarkupConverter;

namespace BoLConsole
{
    public partial class Form1 : Form
    {

        SocketServer Server;

        public Form1()
        {
            InitializeComponent();

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Server = new SocketServer(this);
        }

        public string ConsoleTextBox
        {
            get { return richTextBox1.Text; }
            set 
            {
                string htmltortf = MarkupConverter.HtmlToRtfConverter.ConvertHtmlToRtf("<font color=\"#FFFFFF\">" + value + "</font>");
                richTextBox1.Select(richTextBox1.TextLength, 0);
                richTextBox1.SelectedRtf = htmltortf;
                richTextBox1.ScrollToCaret();
            }
        }

        private void textBox2_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                if(textBox2.Text == "clear")
                {
                    richTextBox1.Rtf = "";
                }
                else
                {
                    richTextBox1.AppendText(">>> " + textBox2.Text + "\n");
                    richTextBox1.ScrollToCaret();
                    Server.SendData(textBox2.Text);
                }
                textBox2.Clear();
                e.Handled = true;
                //e.SuppressKeyPress = true;
            }
        }

        public void enableTextbox()
        {
            textBox2.Enabled = true;
        }
    }
}
