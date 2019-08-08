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
        public MySqlDataReader reader;

        private MySqlCommand cmd;

        public DB()
        {
            connectionString = @"Server=192.168.116.20;Database=eud5;UID=elvisk;Password=%C9cH$ar@M85DpJ!";
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
            cmd = new MySqlCommand("SELECT * FROM fag", _conn);
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

            reader.Close();

            string sql = "INSERT INTO fag (fagnr, tilknyt, opr_varighed, fagnavn) VALUES (@number,@from,@duration,@name)";
            cmd = new MySqlCommand(sql, _conn);
            foreach (Subject subject in subjects)
            {
                bool tester = true;
                foreach (Fag fag in existing_fag)
                {
                    //YIKES
                    if (subject.id == fag.fag_number)
                    {
                        tester = false;
                    }
                }

                if (tester)
                {
                    MySqlParameter fagNumberParam = new MySqlParameter("number", MySqlDbType.UInt16);
                    fagNumberParam.Value = subject.id;
                    MySqlParameter tilknytParam = new MySqlParameter("from", MySqlDbType.VarChar);
                    tilknytParam.Value = subject.@from;
                    MySqlParameter oprVarighedParam = new MySqlParameter("duration", MySqlDbType.VarChar);
                    oprVarighedParam.Value = subject.duration_original;
                    MySqlParameter fagNavnParam = new MySqlParameter("name", MySqlDbType.VarChar);
                    fagNavnParam.Value = subject.name;

                    cmd.Parameters.Add(fagNumberParam);
                    cmd.Parameters.Add(tilknytParam);
                    cmd.Parameters.Add(oprVarighedParam);
                    cmd.Parameters.Add(fagNavnParam);

                    var result = cmd.ExecuteNonQuery();
                    cmd.Parameters.Clear();
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
