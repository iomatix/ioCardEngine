/// A singleton service manager that allows registration and retrieval of services by type.
///
/// This class uses the Singleton pattern with a private constructor and a factory constructor that returns the single instance.
/// It maintains an internal map to store registered services, associating them with their respective types as keys.
///
/// Example usage:
/// ```dart
/// final manager = ServiceManager();
/// manager.register<Logger>(ConsoleLogger());
/// final logger = manager.get<Logger>();
/// ```
class ServiceManager {
  // Private constructor to enforce singleton pattern.
  ServiceManager._internal();

  /// Singleton instance of the service manager.
  static final ServiceManager _instance = ServiceManager._internal();

  /// Factory constructor that returns the singleton instance.
  factory ServiceManager() => _instance;

  /// Internal map to store registered services with their respective types as keys.
  final Map<Type, dynamic> _services = {};

  /// Registers a service in the manager. The type parameter 'T' helps maintain type safety.
  void register<T>(T service) {
    // Assign the provided service to the corresponding type key in the map.
    _services[T] = service;
  }

  /// Retrieves and returns a registered service of type 'T'. Throws an exception if no such service is found.
  T get<T>() {
    // Safely cast the retrieved service to type 'T' using the as operator, which throws a runtime error if casting fails.
    return _services[T] as T;
  }
}
