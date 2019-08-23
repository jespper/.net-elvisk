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

            Console.WriteLine("what ordning_id do you want to do");
            string chosenOrdning = Console.ReadLine();
            var reader = db.Select("SELECT * FROM elevtyperaw WHERE ordning_id = @chosen", chosenOrdning);
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
                    
                    string number = Regex.Match(output,@"^(\d*)").Value;
                    string date = Regex.Match(output, @"(\d\d-\d\d-\d\d\d\d.*)").Value;
                    string tmp = Regex.Match(output, @"(\s.* \d)").Value;
                    string name;
                    if (tmp.Length != 0)
                    {
                        name = tmp.Substring(0, tmp.Length - 1);
                    }
                    else
                    {
                        name = "";
                    }

                    if (number == "")
                    {
                        if (subject.goals.Count == 0)
                        {
                            subject.goals.Add(new Goal("", "9999", ""));
                        }
                        subject.goals[subject.goals.Count - 1].name += name;
                    }
                    else
                    {
                        subject.goals.Add(new Goal(name, number, date));
                    }

                    
                    //Console.WriteLine(output);
                }
                if (output.Contains(@"<PIND+ >"))
                {
                    output = output.Substring(9, output.Length - 10);
                    
                    if (subject.goals.Count == 0)
                    {
                        subject.goals.Add(new Goal("","9999", ""));
                    }

                    subject.goals[subject.goals.Count - 1].name += " " + output;
                }

                if (output.Contains("Administering a SQL Database Infrastructure"))
                {
                    Console.WriteLine("hti");
                }
                #endregion
            }
            subjects.Add(subject);

            subjects.RemoveAt(0);
            Console.WriteLine("Finished getting all the data");
            db.reader.Close();

            db.Create_Speciale(subjects);
            Console.WriteLine("Finished creating subjects");
            
            db.Create_Merged_Fag(subjects);
            Console.WriteLine("Finished creating merged_subjects");

            db.Create_results(subjects);
            Console.WriteLine("Finished creating results");

            db.Create_Goals(subjects);
            Console.WriteLine("Finished creating goals");

            db.Combine_Goals_Subjects(subjects);
            Console.WriteLine("Finished combining subjects and goals");
            //end
            db.Close();
            Console.ReadKey();
        }
    }
}
