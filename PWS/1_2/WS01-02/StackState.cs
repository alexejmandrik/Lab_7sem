namespace WS01_02
{

    public class StackState
    {
        public int Result { get; set; } = 0;

        public Stack<int> Values { get; } = new Stack<int>();

        public readonly object SyncRoot = new object();
    }

}
