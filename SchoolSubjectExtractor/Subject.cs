using System;
using System.Collections.Generic;
using System.Text;

namespace SchoolSubjectExtractor
{
    class Subject
    {
        public string id;
        public string name;
        public string level;
        public string category;
        public string type;
        public string duration_original;
        public string shortening;
        public string duration;
        public string from;
        public List<string> result = new List<string>();
        public List<Goal> goals = new List<Goal>();
    }

    public class Goal
    {
        public string name;
        public List<Goal> subGoals = new List<Goal>();

        public Goal(string name)
        {
            this.name = name;
        }
    }
}
