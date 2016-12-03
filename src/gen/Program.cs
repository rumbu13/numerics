using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace gen
{
    class Program
    {
        private static Random rnd = new Random();
        static BigInteger GetRandom(int minBits, int maxBits, bool acceptNegatives = false)
        {
            byte[] bytes = new byte[rnd.Next(minBits / 8, maxBits / 8 + 1)];
            rnd.NextBytes(bytes);
            if (!acceptNegatives)
                bytes[bytes.Length - 1] &= (byte)0x7F;
            return new BigInteger(bytes);                        
        }

        static uint[] GetArray(BigInteger big)
        {
            var bytes = big.ToByteArray();
            while (bytes.Length > 0 && bytes[bytes.Length - 1] == 0)
            {
                Array.Resize(ref bytes, bytes.Length - 1);
            }
            if (bytes.Length % 4 != 0)
            {
                Array.Resize(ref bytes, (bytes.Length / 4) * 4 + 4);
            }
            uint[] ret = new uint[bytes.Length / 4];
            for (int i = 0; i < ret.Length; ++i)
                ret[i] = BitConverter.ToUInt32(bytes, i * 4);
            return ret;
        }

        static int GetSize(BigInteger big)
        {
            var bytes = big.ToByteArray();
            return bytes.Length % 4 != 0 ? ((bytes.Length / 4) * 4 + 4) * 8 : bytes.Length * 8;
        }

        static string GetHexArray(BigInteger b)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("[");
            var u = GetArray(b);
            for (int i = 0; i < u.Length - 1; ++i)
                sb.AppendFormat("0x{0:X8}, ", u[i]);
            if (u.Length > 0)
                sb.AppendFormat("0x{0:X8}", u[u.Length - 1]);
            sb.Append("]");
            return sb.ToString();
        }

        static void Main(string[] args)
        {
            string dataFile = @"..\src\test\data.d";
            int samples = 100;

            StringBuilder sb = new StringBuilder("module data;");
            sb.AppendLine();
            sb.AppendLine();
            sb.AppendLine("struct mu { uint[] left; uint right; uint[] result; }");
            sb.AppendLine();
            sb.AppendLine("mu[] mul_uint_data = [");
            for (int i = 0; i < samples; ++i)
            {
                BigInteger big = GetRandom(32, 128);
                uint u = (uint)rnd.Next(int.MinValue, int.MaxValue);
                BigInteger ret = big * u;
                sb.AppendFormat("  mu({0},", GetHexArray(big));
                sb.AppendLine();
                sb.AppendFormat("     0x{0:X8},", u);
                sb.AppendLine();
                sb.AppendFormat("     {0}),", GetHexArray(ret));
                sb.AppendLine();
                sb.AppendFormat("  //0x{0:X} * 0x{1:X} = 0x{2:X}", big, u, ret);
                sb.AppendLine();
            }
            sb.AppendLine("];");


            sb.AppendLine();
            sb.AppendLine("struct ma { uint[] left; uint[] right; uint[] result; }");
            sb.AppendLine();
            sb.AppendLine("ma[] mul_array_data = [");
            for (int i = 0; i < samples; ++i)
            {
                BigInteger big = GetRandom(32, 128);
                BigInteger big2 = GetRandom(32, 128);
                BigInteger ret = big * big2;
                sb.AppendFormat("  ma({0},", GetHexArray(big));
                sb.AppendLine();
                sb.AppendFormat("     {0},", GetHexArray(big2));
                sb.AppendLine();
                sb.AppendFormat("     {0}),", GetHexArray(ret));
                sb.AppendLine();
                sb.AppendFormat("  //0x{0:X} * 0x{1:X} = 0x{2:X}", big, big2, ret);
                sb.AppendLine();
            }
            sb.AppendLine("];");


            sb.AppendLine();
            sb.AppendLine("struct du { uint[] left; uint right; uint[] result; uint[] remainder; }");
            sb.AppendLine();
            sb.AppendLine("du[] div_uint_data = [");
            for (int i = 0; i < samples; ++i)
            {
                BigInteger big = GetRandom(32, 128);
                uint u = (uint)rnd.Next(int.MinValue, int.MaxValue);
                BigInteger ret = big / u;
                BigInteger rem = big % u;
                sb.AppendFormat("  du({0},", GetHexArray(big));
                sb.AppendLine();
                sb.AppendFormat("     0x{0:X8},", u);
                sb.AppendLine();
                sb.AppendFormat("     {0},", GetHexArray(ret));
                sb.AppendLine();
                sb.AppendFormat("     {0}),", GetHexArray(rem));
                sb.AppendLine();
                sb.AppendFormat("  //0x{0:X} / 0x{1:X} = 0x{2:X}, 0x{3:X}", big, u, ret, rem);
                sb.AppendLine();
            }
            sb.AppendLine("];");


            sb.AppendLine();
            sb.AppendLine("struct da { uint[] left; uint[] right; uint[] result; uint[] remainder; }");
            sb.AppendLine();
            sb.AppendLine("da[] div_array_data = [");
            for (int i = 0; i < samples; ++i)
            {
                BigInteger big = GetRandom(32, 128);
                BigInteger big2 = GetRandom(32, 128);
                while (big2 > big)
                    big2 = GetRandom(32, 128);
                BigInteger ret = big / big2;
                BigInteger rem = big % big2;
                sb.AppendFormat("  da({0},", GetHexArray(big));
                sb.AppendLine();
                sb.AppendFormat("     {0},", GetHexArray(big2));
                sb.AppendLine();
                sb.AppendFormat("     {0},", GetHexArray(ret));
                sb.AppendLine();
                sb.AppendFormat("     {0}),", GetHexArray(rem));
                sb.AppendLine();
                sb.AppendFormat("  //0x{0:X} / 0x{1:X} = 0x{2:X}, 0x{3:X}", big, big2, ret, rem);
                sb.AppendLine();
            }
            sb.AppendLine("];");

            //BigInteger b1 = BigInteger.Parse("85C572A26A2BFE5A", System.Globalization.NumberStyles.AllowHexSpecifier);
            //uint u1 = 0xD326EA77;
            //BigInteger ret1 = b1 * u1;

            //Console.WriteLine(ret1.ToString("X"));
            //Console.WriteLine(GetHexArray(b1));
            //Console.WriteLine("{0:X8}", u1);
            //Console.WriteLine(GetHexArray(ret1));

            sb.AppendLine();
            sb.AppendLine("struct ss { uint size; string left, right, addresult, subresult, mulresult, divresult, remresult; }");
            sb.AppendLine();
            sb.AppendLine("ss[] ss_data = [");
            for (int i = 0; i < samples; ++i)
            {
                BigInteger left = GetRandom(32, 96, true);
                BigInteger right = GetRandom(32, 96, true);
                int sz = 96;
                if (sz < GetSize(left))
                    sz = GetSize(left);
                if (sz < GetSize(right))
                    sz = GetSize(right);
                if (sz < GetSize(left + right))
                    sz = GetSize(left + right);
                if (sz < GetSize(left - right))
                    sz = GetSize(left - right);
                if (sz < GetSize(left * right))
                    sz = GetSize(left * right);
                if (sz < GetSize(left / right))
                    sz = GetSize(left / right);
                if (sz < GetSize(left % right))
                    sz = GetSize(left % right);

                sb.AppendFormat("  ss({0},", sz);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", left);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", right);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", left + right);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", left - right);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", left * right);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\",", left / right);
                sb.AppendLine();
                sb.AppendFormat("     \"{0}\"),", left % right);
                sb.AppendLine();
            }
            sb.AppendLine("];");

            File.WriteAllText(dataFile, sb.ToString());

            Console.ReadLine();
        }
    }
}
