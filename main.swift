import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible, Codable {
    var id: UUID = UUID()
    let title: String
    var isCompleted: Bool = false
    var description: String {
        return "\(title). \(isCompleted ? "✅":"❌")"
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    private let fileName = "todos.json"
    
    private var fileURL: URL? {
        do {
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return documentDirectory.appendingPathComponent(fileName)
        } catch {
            print("Error finding document directory: \(error)")
            return nil
        }
    }
    
    func save(todos: [Todo]) {
        guard let fileURL = fileURL else { return }
        
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Error saving todos: \(error)")
        }
    }
    
    func load() -> [Todo]? {
        guard let fileURL = fileURL else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            return todos
        } catch {
            print("Error loading todos: \(error)")
            return nil
        }
    }
    

}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session.
// This won't retain todos across different app launches,
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    private var todos: [Todo] = []
    
    func save(todos: [Todo]) {
        self.todos = todos
    }
    
    func load() -> [Todo]? {
        return todos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    var todos: [Todo] = []
    
    func listTodos(){
        if !todos.isEmpty {
            print("📝 Your Todos:")
            for (index , todo) in todos.enumerated() {
                print("\(index + 1)) \(todo.description)")
            }
        } else {
            print("🤖 There is no todo!")
        }
    }
    
    func addTodo(with title: String){
        let newTodo = Todo(title: title)
        todos.append(newTodo)
        print("📌 Todo added!")
    }
    
    func toggleCompletion(forTodoAtIndex index: Int){
        let todoIndex = index - 1
        if todoIndex >= 0 && todoIndex < todos.count {
            todos[todoIndex].isCompleted.toggle()
        }
        print("🔄 Todo completion status toggled!")
    }
    
    func deleteTodo(atIndex index: Int){
        let todoIndex = index - 1
        if todoIndex >= 0 && todoIndex < todos.count {
            todos.remove(at: todoIndex)
        }
        print("🗑️ Todo deleted!")
    }
    
    
}


// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class
final class App {
    
    let manager = TodoManager()
    
    enum Operations: String {
        case add    = "add"
        case list   = "list"
        case toggle = "toggle"
        case delete = "delete"
        case exit   = "exit"
    }
    
    func run() {
        print("💫 Welcome to Todo CLI! 💫")
        
        var isActive = true
        
        while isActive {
            print("What would you like to do? (add, list, toggle, delete, exit): ")
            
            if let input = readLine()?.lowercased(), let opr = Operations(rawValue: input) {
                switch opr {
                case .add:
                    print("Add the todo title:")
                    if let input = readLine()?.lowercased(){
                        manager.addTodo(with: input)
                    } else {
                      print("Something went wrong try again")
                    }
                    
                case .list:
                    manager.listTodos()
                case .toggle:
                    print("Enter the todo number:")
                    if let input = readLine(), let index = Int(input) {
                        manager.toggleCompletion(forTodoAtIndex: index)

                    } else {
                        print("Something went wrong try again")
                    }
                case .delete:
                    print("Enter the todo number to delete: ")
                    if let input = readLine(), let index = Int(input) {
                        manager.deleteTodo(atIndex: index)
                    } else {
                        print("Something went wrong try again")
                    }
                case .exit:
                    isActive = false
                    print("👋 Thank you for using Todo CLI! See you next time!")
                   
                }
                
            }
            
        }
        
    }
    
    
}


// TODO: Write code to set up and run the app.
let main = App()
main.run()

