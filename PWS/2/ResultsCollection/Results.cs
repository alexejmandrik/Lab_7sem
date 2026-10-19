using System.Text.Json;

namespace ResultsCollection;

public class Result
{
    public int Id { get; set; }

    public string Value { get; set; } = "";
}

public class Results
{
    private readonly string _filePath;

    private static readonly object _fileLock = new object();

    public Results()
    {
        _filePath = Path.Combine(AppContext.BaseDirectory, "results.json");

        if (!File.Exists(_filePath))
        {
            File.WriteAllText(_filePath, "[]");
        }
    }

    public List<Result> GetAll()
    {
        lock (_fileLock)
        {
            return ReadResults();
        }
    }

    public Result? Get(int id)
    {
        lock (_fileLock)
        {
            var results = ReadResults();

            return results.FirstOrDefault(x => x.Id == id);
        }
    }

    public Result Add(string value)
    {
        lock (_fileLock)
        {
            var results = ReadResults();

            int newId = results.Count == 0
                ? 1
                : results.Max(x => x.Id) + 1;

            var result = new Result
            {
                Id = newId,
                Value = value
            };

            results.Add(result);

            WriteResults(results);

            return result;
        }
    }

    public Result? Update(int id, string value)
    {
        lock (_fileLock)
        {
            var results = ReadResults();

            var result = results.FirstOrDefault(x => x.Id == id);

            if (result == null)
                return null;

            result.Value = value;

            WriteResults(results);

            return result;
        }
    }

    public Result? Delete(int id)
    {
        lock (_fileLock)
        {
            var results = ReadResults();

            var result = results.FirstOrDefault(x => x.Id == id);

            if (result == null)
                return null;

            results.Remove(result);

            WriteResults(results);

            return result;
        }
    }

    private List<Result> ReadResults()
    {
        if (!File.Exists(_filePath))
            return new List<Result>();

        string json = File.ReadAllText(_filePath);

        if (string.IsNullOrWhiteSpace(json))
            return new List<Result>();

        return JsonSerializer.Deserialize<List<Result>>(json)
               ?? new List<Result>();
    }

    private void WriteResults(List<Result> results)
    {
        var options = new JsonSerializerOptions
        {
            WriteIndented = true
        };

        string json = JsonSerializer.Serialize(results, options);

        File.WriteAllText(_filePath, json);
    }
}