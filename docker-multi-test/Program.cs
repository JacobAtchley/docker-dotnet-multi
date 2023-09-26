using docker_multi_test_lib;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapGet("/api/people", PersonRepository.GetAll);

await app.RunAsync();