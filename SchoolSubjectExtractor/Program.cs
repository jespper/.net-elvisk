using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;
using Org.BouncyCastle.X509.Extension;

namespace SchoolSubjectExtractor
{
    class Program
    {
        private static List<Subject> subjects = new List<Subject>();
        static void Main(string[] args)
        {
            DB db = new DB();
            if (!db.Status())
            {
                return;
            }
            var reader = db.Select("SELECT * FROM elevtyperaw");
            Subject subject = new Subject();
            while (reader.Read())
            {
                string output = reader.GetString(1);
                //Console.WriteLine(tmpOutput);

                #region more beutiful

                if (output.Contains(@"<FAG   >"))
                {
                    subjects.Add(subject);
                    subject = new Subject();
                    output = output.Substring(9, output.Length - 10);
                    //Console.WriteLine(output);
                    var split = output.Split(" ");
                    subject.id = split[0];
                    split = split.Skip(1).ToArray();
                    subject.name = string.Join(" ", split);
                }
                if (output.Contains(@"<NIVEAU>"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.level = output;
                }
                if (output.Contains(@"<OPRVAR>"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.duration_original = output;
                }
                if (output.Contains(@"<FAGKAT>"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.category = output;
                }
                if (output.Contains(@"<TYPE  >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.type = output;
                }
                if (output.Contains(@"<FRA   >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.from = output;
                }
                if (output.Contains(@"<AFKORT>"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.shortening = output;
                }
                if (output.Contains(@"<VARIG >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.duration = output;
                }
                if (output.Contains(@"<RESUL"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.result.Add(output);
                }
                if (output.Contains(@"<PIND  >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    subject.goals.Add(new Goal(output));
                    //Console.WriteLine(output);
                }
                if (output.Contains(@"<PIND+ >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    //Console.WriteLine(output);
                    //Console.WriteLine(subject.goals.Count);
                    
                    if (subject.goals.Count == 0)
                    {
                        subject.goals.Add(new Goal(""));
                    }
                    subject.goals[subject.goals.Count - 1].subGoals.Add(new Goal(output));
                    
                }
                #endregion
            }
            subjects.Add(subject);

            subjects.RemoveAt(0);
            db.reader.Close();
            db.Create_Speciale(subjects);


            //end
            db.Close();
            Console.ReadKey();
        }
    }
}
