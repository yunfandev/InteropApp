using NativeLib;
using System;

namespace InteropApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(new InteropHelper().Sum(1, 2));
            Console.WriteLine("Hello World!");
        }
    }
}
