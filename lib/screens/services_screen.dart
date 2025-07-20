import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/service.dart';
import '../services/api_service.dart';

// State classes for better state management
class ServicesState {
  final List<Service> services;
  final List<Service> filteredServices;
  final List<String> categories;
  final String? selectedCategory;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const ServicesState({
    this.services = const [],
    this.filteredServices = const [],
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  ServicesState copyWith({
    List<Service>? services,
    List<Service>? filteredServices,
    List<String>? categories,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return ServicesState(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// Riverpod providers
class ServicesNotifier extends StateNotifier<ServicesState> {
  final ApiService _apiService;

  ServicesNotifier(this._apiService) : super(const ServicesState());

  Future<void> loadServices() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load services and categories concurrently
      final futures = await Future.wait([
        _apiService.getServices(),
        _apiService.getServiceCategories(),
      ]);

      final servicesResponse = futures[0] as ServicesResponse;
      final categories = futures[1] as List<String>;

      final allCategories = ['All', ...categories];
      final filteredServices = _filterServices(servicesResponse.services, state.selectedCategory);

      state = state.copyWith(
        services: servicesResponse.services,
        filteredServices: filteredServices,
        categories: allCategories,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> refreshServices() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final servicesResponse = await _apiService.getServices();
      final filteredServices = _filterServices(servicesResponse.services, state.selectedCategory);

      state = state.copyWith(
        services: servicesResponse.services,
        filteredServices: filteredServices,
        isRefreshing: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: _getErrorMessage(e),
      );
    }
  }

  void filterByCategory(String? category) {
    final selectedCategory = (category == null || category == 'All') ? null : category;
    final filteredServices = _filterServices(state.services, selectedCategory);

    state = state.copyWith(
      selectedCategory: selectedCategory,
      filteredServices: filteredServices,
    );
  }

  List<Service> _filterServices(List<Service> services, String? category) {
    if (category == null || category.isEmpty) {
      return services;
    }
    return services.where((service) => 
        service.category.toLowerCase() == category.toLowerCase()).toList();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is TimeoutException) {
      return error.message;
    } else if (error is ServerException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier(ApiServiceProvider.instance);
});

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Load services when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(servicesProvider.notifier).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);
    final notifier = ref.read(servicesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isRefreshing ? null : () => notifier.refreshServices(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          if (state.categories.isNotEmpty) _buildFilterSection(state, notifier),
          
          // Content Section
          Expanded(
            child: _buildContent(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ServicesState state, ServicesNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Filter by Category:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.selectedCategory ?? 'All',
                isExpanded: true,
                items: state.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    notifier.filterByCategory(value == 'All' ? null : value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ServicesState state, ServicesNotifier notifier) {
    if (state.isLoading && state.services.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.services.isEmpty) {
      return _buildErrorState(state.error!, notifier);
    }

    if (state.services.isEmpty) {
      return _buildEmptyState(notifier);
    }

    return _buildServicesList(state, notifier);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading services...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ServicesNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                notifier.clearError();
                notifier.loadServices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ServicesNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Services Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no services to display at the moment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => notifier.loadServices(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(ServicesState state, ServicesNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.refreshServices(),
      child: Column(
        children: [
          // Error banner (if error during refresh)
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => notifier.clearError(),
                  ),
                ],
              ),
            ),
          
          // Services count
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Text(
                  '${state.filteredServices.length} service${state.filteredServices.length != 1 ? 's' : ''} found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (state.selectedCategory != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(state.selectedCategory!),
                    onDeleted: () => notifier.filterByCategory(null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ],
            ),
          ),
          
          // Services list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              itemCount: state.filteredServices.length,
              itemBuilder: (context, index) {
                final service = state.filteredServices[index];
                return _buildServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(service.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(service.category),
                      color: _getCategoryColor(service.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(service.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.category,
                            style: TextStyle(
                              color: _getCategoryColor(service.category),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rating
                  if (service.averageRating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            service.formattedRating,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Description
              if (service.description != null && service.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  service.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Price and status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.formattedPrice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: service.isActive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: service.isActive ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'internet':
        return Colors.blue;
      case 'cable':
        return Colors.purple;
      case 'snacks':
        return Colors.orange;
      case 'silver':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'internet':
        return Icons.wifi;
      case 'cable':
        return Icons.tv;
      case 'snacks':
        return Icons.fastfood;
      case 'silver':
        return Icons.star;
      default:
        return Icons.miscellaneous_services;
    }
  }

  void _showServiceDetails(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Service details
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Category: ${service.category}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Price: ${service.formattedPrice}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (service.averageRating > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${service.formattedRating} rating',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                        if (service.description != null && service.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Status: ${service.isActive ? "Active" : "Inactive"}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: service.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: service.isActive ? () {
                      Navigator.pop(context);
                      // TODO: Navigate to service subscription/purchase
                    } : null,
                    child: Text(service.isActive ? 'Subscribe' : 'Not Available'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
