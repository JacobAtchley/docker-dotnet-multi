namespace docker_multi_test_lib;

public static class PersonRepository
{
    private static readonly Dictionary<int, Person> People = new()
    {
        { 1, new Person() { Age = 30, Phone = "123-456-7890", FirstName = "Bob", LastName = "Smith" } },
        { 2, new Person() { Age = 31, Phone = "9876-543-210", FirstName = "George", LastName = "Smith" } },
    };

    public static IEnumerable<Person> GetAll() => People.Values;
}