using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
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

        public MySqlDataReader Select(string query, string chosen)
        {
            //string query = "SELECT * FROM elevtyperaw";
            cmd = new MySqlCommand(query, _conn);
            cmd.Parameters.Add(new MySqlParameter("chosen", MySqlDbType.UInt16) {Value = chosen});
            _conn.Open();
            reader = cmd.ExecuteReader();
            return reader;
        }

        public void Create_Speciale(List<Subject> subjects)
        {   
            cmd = new MySqlCommand("SELECT * FROM fag", _conn);
            List<Fag> existing_fag = new List<Fag>();
            List<string> ids_created = new List<string>();
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
                    bool tmp = false;
                    foreach (string s in ids_created)
                    {
                        if (s == subject.id)
                        {
                            tmp = true;
                        }
                    }

                    if (tmp)
                    {
                        continue;
                    }
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

                    ids_created.Add(subject.id);
                }
            }
        }

        public void Create_Merged_Fag(List<Subject> subjects)
        {
            cmd = new MySqlCommand("SELECT * FROM faginstans i LEFT JOIN fag f ON f.fag_id = i.fag_id", _conn);

            List<Merged_Fag> fags = new List<Merged_Fag>();
            reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                string level = reader.GetString(1);
                string category = reader.GetString(2);
                string fag_type = reader.GetString(3);
                string duration_original = reader.GetString(4);
                string shortening = reader.GetString(5);
                string duration = reader.GetString(6);
                string id = reader.GetString(9);
                Merged_Fag fag = new Merged_Fag(id,level,category,fag_type,duration_original,shortening,duration);
                fags.Add(fag);
            }

            reader.Close();
            List<Subject> tmp = new List<Subject>();
            string sql = "INSERT INTO faginstans (niveau, fagkat, fagtype, opr_varighed, afkortning, varighed, fag_id) VALUES (@level,@cat,@type,@duration_original,@short,@duration, (SELECT fag_id FROM fag WHERE fagnr = @id))";
            cmd = new MySqlCommand(sql, _conn);

            foreach (Subject subject in subjects)
            {
                bool tester = true;
                foreach (Merged_Fag mergedFag in fags)
                {
                    if (subject.id == mergedFag.id && subject.level == mergedFag.level && subject.type == mergedFag.type && subject.category == mergedFag.category)
                    {
                        tester = false;
                    }
                }

                if (tester)
                {
                    MySqlParameter param;

                    bool tmpbool = false;
                    foreach (Subject s in tmp)
                    {
                        if (subject.id == s.id && subject.level == s.level && subject.type == s.type && subject.category == s.category)
                        {
                            tmpbool = true;
                        }
                    }

                    if (tmpbool)
                    {
                        continue;
                    }

                    param = new MySqlParameter("level", MySqlDbType.VarChar);
                    param.Value = subject.level;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("cat", MySqlDbType.VarChar);
                    param.Value = subject.category;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("type", MySqlDbType.VarChar);
                    param.Value = subject.type;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("duration_original", MySqlDbType.VarChar);
                    param.Value = subject.duration_original;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("short", MySqlDbType.VarChar);
                    param.Value = subject.shortening;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("duration", MySqlDbType.VarChar);
                    param.Value = subject.duration;
                    cmd.Parameters.Add(param);

                    param = new MySqlParameter("id", MySqlDbType.UInt16);
                    param.Value = subject.id;
                    cmd.Parameters.Add(param);

                    var result = cmd.ExecuteNonQuery();
                    cmd.Parameters.Clear();

                    tmp.Add(subject);
                }
            }
        }

        public void Create_results(List<Subject> subjects)
        {
            cmd = new MySqlCommand("SELECT * FROM resultatform", _conn);

            List<Result> results = new List<Result>();
            reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                string result = reader.GetString(1);
                string id = reader.GetString(2);
                Result fag = new Result(result, id);
                results.Add(fag);
            }

            reader.Close();

            string sql = "INSERT INTO resultatform (resultatform, faginstans_id) VALUES (@result, (SELECT i.faginstans_id FROM faginstans i LEFT JOIN fag f ON f.fag_id = i.fag_id WHERE f.fagnr = @id && i.niveau = @level && i.fagkat = @cat && i.fagtype = @type))";
            cmd = new MySqlCommand(sql, _conn);

            foreach (Subject subject in subjects)
            {
                bool tester = true;
                foreach (Result result in results)
                {
                    if (subject.result.Contains(result.result))
                    {
                        tester = false;
                    }
                }

                if (tester)
                {
                    MySqlParameter param;

                    foreach (string  s in subject.result)
                    {
                        param = new MySqlParameter("result", MySqlDbType.VarChar);
                        param.Value = s;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("level", MySqlDbType.VarChar);
                        param.Value = subject.level;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("cat", MySqlDbType.VarChar);
                        param.Value = subject.category;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("type", MySqlDbType.VarChar);
                        param.Value = subject.type;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("id", MySqlDbType.VarChar);
                        param.Value = subject.id;
                        cmd.Parameters.Add(param);

                        var result = cmd.ExecuteNonQuery();
                        cmd.Parameters.Clear();
                    }
                }
            }
        }

        public void Create_Goals(List<Subject> subjects)
        {
            cmd = new MySqlCommand("SELECT * FROM pind", _conn);

            List<Goal> goals = new List<Goal>();
            List<Goal> already_added = new List<Goal>();
            reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                string number = reader.GetString(1);
                string name = reader.GetString(2);
                string date = reader.GetString(3);
                Goal goal = new Goal(name, number, date);
                goals.Add(goal);
            }

            reader.Close();

            string sql = "INSERT INTO pind (pindnr, pind, dato) VALUES (@number, @name, @date )";
            cmd = new MySqlCommand(sql, _conn);

            foreach (Subject subject in subjects)
            {
                bool tester = true;
                foreach (Goal goal in goals)
                {
                    foreach (Goal tmpGoal in subject.goals)
                    {
                        if (goal.name == tmpGoal.name)
                        {
                            tester = false;
                        }
                    }
                }

                if (tester)
                {
                    MySqlParameter param;

                    foreach (Goal s in subject.goals)
                    {
                        bool tmp = false;
                        foreach (Goal goal in already_added)
                        {
                            if (goal.name == s.name)
                            {
                                tmp = true;
                            }
                        }

                        if (tmp)
                        {
                            continue;
                        }
                        param = new MySqlParameter("number", MySqlDbType.VarChar);
                        param.Value = s.number;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("name", MySqlDbType.VarChar);
                        param.Value = s.name;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("date", MySqlDbType.VarChar);
                        param.Value = s.date;
                        cmd.Parameters.Add(param);

                        var result = cmd.ExecuteNonQuery();
                        cmd.Parameters.Clear();
                        already_added.Add(s);
                    }
                }
            }
        }

        public void Combine_Goals_Subjects(List<Subject> subjects)
        {
            cmd = new MySqlCommand(@"SELECT fag.fagnr, fag.fagnavn, faginstans.niveau, faginstans.fagtype, faginstans.fagkat, pind.pind, pind.pind_id, faginstans.faginstans_id
                                            FROM faginstans 
                                            JOIN fag ON fag.fag_id = faginstans.fag_id 
                                            LEFT OUTER JOIN kombiner_fag_pin ON faginstans.faginstans_id = kombiner_fag_pin.faginstans_id
                                            LEFT OUTER JOIN pind ON pind.pind_id = kombiner_fag_pin.pind_id", _conn);
            reader = cmd.ExecuteReader();

            List<Combined_Goal_Subject> combined = new List<Combined_Goal_Subject>();
            List<Subject> already_created = new List<Subject>();

            while (reader.Read())
            {
                string pindId;
                string faginstansId;
                if (!reader.IsDBNull(6))
                {
                    pindId = reader.GetString(6);
                }
                else
                {
                    pindId = "";
                }

                if (!reader.IsDBNull(7))
                {
                    faginstansId = reader.GetString(7);
                }
                else
                {
                    faginstansId = "";
                }

                string name = !reader.IsDBNull(5) ? reader.GetString(5) : "";
                
                string level = reader.GetString(2);
                string type = reader.GetString(3);
                string cat = reader.GetString(4);
                Combined_Goal_Subject tmp = new Combined_Goal_Subject(pindId, faginstansId, name, level, type, cat);
                combined.Add(tmp);
            }
            reader.Close();

            foreach (Subject subject in subjects)
            {
                bool tester = true;
                foreach (Combined_Goal_Subject combinedGoalSubject in combined)
                {
                    foreach (Goal subjectGoal in subject.goals)
                    {
                        if (subjectGoal.name == combinedGoalSubject.goal.name)
                        {
                            tester = false;
                        }
                    }
                }

                if (tester)
                {
                    MySqlParameter param;
                    string sql =
                        "INSERT INTO kombiner_fag_pin (pind_id, faginstans_id) VALUES ((SELECT pind_id FROM pind where pind LIKE @pind),(SELECT faginstans_id FROM faginstans left join fag on fag.fag_id = faginstans.fag_id WHERE fagkat = @cat && fagtype = @type && niveau = @level && fag.fagnavn = @name))";
                    
                    cmd = new MySqlCommand(sql, _conn);

                    foreach (Goal goal in subject.goals)
                    {
                        param = new MySqlParameter("pind", MySqlDbType.VarChar);
                        param.Value = MySqlHelper.EscapeString(goal.name);
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("cat", MySqlDbType.VarChar);
                        param.Value = subject.category;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("type", MySqlDbType.VarChar);
                        param.Value = subject.type;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("level", MySqlDbType.VarChar);
                        param.Value = subject.level;
                        cmd.Parameters.Add(param);

                        param = new MySqlParameter("name", MySqlDbType.VarChar);
                        param.Value = subject.name;
                        cmd.Parameters.Add(param);

                        var result = cmd.ExecuteNonQuery();
                        cmd.Parameters.Clear();
                        already_created.Add(subject);
                    }
                }
            }
            Console.WriteLine("a");
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

    class Merged_Fag
    {
        public string id;
        public string level;
        public string category;
        public string type;
        public string duration_original;
        public string shortening;
        public string duration;

        public Merged_Fag(string id, string level, string category, string type, string durationOriginal, string shortening, string duration)
        {
            this.id = id;
            this.level = level;
            this.category = category;
            this.type = type;
            duration_original = durationOriginal;
            this.shortening = shortening;
            this.duration = duration;
        }
    }

    class Result
    {
        public string result;
        public string id;

        public Result(string result, string id)
        {
            this.result = result;
            this.id = id;
        }
    }

    class Combined_Goal_Subject
    {
        public string pind_id;
        public string faginstans_id;
        public Goal goal;
        public Subject subject = new Subject();

        public Combined_Goal_Subject(string pindId, string faginstansId, string name, string level, string type, string cat)
        {
            pind_id = pindId;
            faginstans_id = faginstansId;
            this.goal = new Goal(name, "", "");
            this.subject.level = level;
            this.subject.type = type;
            this.subject.category = cat;
        }
    }
}
