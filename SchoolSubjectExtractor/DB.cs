using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Text;
using Renci.SshNet.Messages.Connection;

namespace SchoolSubjectExtractor
{
    class DB
    {
        private string connectionString;
        private readonly MySqlConnection _conn;
        private MySqlDataReader reader;

        private MySqlCommand cmd;

        public DB()
        {
            connectionString = @"Server=192.168.116.20;Database=eud5;UID=root;Password=*athe3+UKUgA";
            _conn = new MySqlConnection(connectionString);
        }

        public void Close()
        {   
            _conn.Close();
            reader.Dispose();
        }
        public bool Status()
        {
            try
            {
                _conn.Open();
                _conn.Close();
                return true;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.WriteLine("_connection not successfull");
                return false;
            }
        }

        public MySqlDataReader Select(string query)
        {
            //string query = "SELECT * FROM elevtyperaw";
            cmd = new MySqlCommand(query, _conn);
            _conn.Open();
            reader = cmd.ExecuteReader();
            return reader;
        }

        public void Create_Speciale(List<Subject> subjects)
        {
            cmd = new MySqlCommand("SELECT * FROM fag");
            List<Fag> existing_fag = new List<Fag>();
            List<Fag> new_fag = new List<Fag>();
            reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                string id = reader.GetString(0);
                string name = reader.GetString(4);
                string from = reader.GetString(2);
                string duration_original = reader.GetString(3);
                string fag_number = reader.GetString(1);
                Fag fag = new Fag(id,fag_number,from,duration_original,name);
                existing_fag.Add(fag);
            }
            string sql = 
            foreach (Subject subject in subjects)
            {
                foreach (Fag fag in existing_fag)
                {
                    if (subject.id != fag.fag_number)
                    {

                    }
                }
            }
        }
    }

    class Fag
    {
        public string id;
        public string name;
        public string from;
        public string fag_number;
        public string duration_original;

        public Fag(string id, string fagNumber, string from, string durationOriginal, string name)
        {
            this.id = id;
            this.name = name;
            this.from = from;
            fag_number = fagNumber;
            duration_original = durationOriginal;
        }
    }
}
