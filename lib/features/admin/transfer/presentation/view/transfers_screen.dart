
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:GoSystem/core/constants/app_colors.dart';
// import 'package:GoSystem/core/utils/responsive_ui.dart';
// import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
// import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
// import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
// import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
// import 'package:GoSystem/features/admin/transfer/cubit/transfers_cubit.dart';
// import 'package:GoSystem/features/admin/transfer/presentation/widgets/create_transfer_dialog.dart';
// import 'package:GoSystem/features/admin/transfer/presentation/widgets/transfer_card.dart';
// import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
// import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';


// import 'package:GoSystem/generated/locale_keys.g.dart';

// class TransfersScreen extends StatelessWidget {
//   const TransfersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => TransfersCubit()),
//         BlocProvider(create: (context) => WareHouseCubit()..getWarehouses()),
//       ],
//       child: const TransfersView(),
//     );
//   }
// }

// class TransfersView extends StatefulWidget {
//   const TransfersView({super.key});

//   @override
//   State<TransfersView> createState() => _TransfersViewState();
// }

// class _TransfersViewState extends State<TransfersView> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
  
//   String? _selectedWarehouseId;
  
//   bool _showWarehouseSelector = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
    
//     // Hide dropdown on History tab (index 2)
//     _tabController.addListener(() {
//       setState(() {
//         _showWarehouseSelector = _tabController.index != 0;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBarWithActions(
//         context,
//         title: LocaleKeys.transfers.tr(),
//         showActions: true,
//         onPressed: () => showDialog(
//           context: context,
//           builder: (context) => const CreateTransferDialog(),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildTabBar(context),
          
//           // --- Warehouse Selector (Using Existing Cubit) ---
//           if (_showWarehouseSelector) 
//             _buildWarehouseFilter(context),

//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 const _AllTransfersList(),
//                 // Tab 1: Incoming
//                 _IncomingTransfersList(warehouseId: _selectedWarehouseId),
                
//                 // Tab 2: Outgoing
//                 _OutgoingTransfersList(warehouseId: _selectedWarehouseId),
                
//                 // Tab 3: History (Does not need ID)
                
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         labelColor: AppColors.primaryBlue,
//         unselectedLabelColor: AppColors.darkGray,
//         indicatorColor: AppColors.primaryBlue,
//         tabs: [
//           Tab(text: LocaleKeys.all_transfers.tr(), icon: Icon(Icons.transfer_within_a_station)),
//           Tab(text: LocaleKeys.incoming.tr(), icon: Icon(Icons.move_to_inbox)),
//           Tab(text: LocaleKeys.outgoing.tr(), icon: Icon(Icons.outbox)),
          
//         ],
//       ),
//     );
//   }

//   // --- Logic to build dropdown from WarehousesCubit ---
//   Widget _buildWarehouseFilter(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: ResponsiveUI.padding(context, 16),
//         vertical: ResponsiveUI.padding(context, 12),
//       ),
//       color: Colors.grey[50],
//       child: BlocBuilder<WareHouseCubit, WarehousesState>(
//         builder: (context, state) {
//           if (state is WarehousesLoading) {
//             return const LinearProgressIndicator();
//           } 

//           if (state is WarehousesLoaded) {
//             final warehouses = state.warehouses;

//             if (_selectedWarehouseId != null &&
//                 !warehouses.any((w) => w.id == _selectedWarehouseId)) {
//               _selectedWarehouseId = null;
//             }

//             String? selectedName;
//             if (_selectedWarehouseId != null) {
//               try {
//                 selectedName = warehouses
//                     .firstWhere((w) => w.id == _selectedWarehouseId)
//                     .name;
//               } catch (e) {
//                 _selectedWarehouseId = null; // Reset if not found
//               }
//             }
            
      

//           return buildDropdownField<String>(
//               context,
//               // ERROR WAS HERE: Pass the Name, not the ID, because items are Names
//               value: selectedName, 
//               items: warehouses.map((e) => e.name).toList(),
//               hint: LocaleKeys.select_warehouse.tr(),
//               label: "Filter by Warehouse",
//               icon: Icons.store,
//               onChanged: (nameValue) {
//                 if (nameValue == null) return;
//                 // Reverse Lookup: Get ID from the selected Name
//                 final selectedWarehouse = warehouses.firstWhere((e) => e.name == nameValue);
//                 setState(() {
//                   _selectedWarehouseId = selectedWarehouse.id;
//                 });
//               },
//               itemLabel: (name) => name,
//             );
//           }
          
//           if (state is WarehousesError) {
//              return Text(state.message, style: TextStyle(color: Colors.red));
//           }

//           return SizedBox(); // Initial state
//         },
//       ),
//     );
//   }
// }

// // --- The Tabs (Identical to previous logic, just receiving the ID) ---

// class _IncomingTransfersList extends StatefulWidget {
//   final String? warehouseId;
//   const _IncomingTransfersList({this.warehouseId});

//   @override
//   State<_IncomingTransfersList> createState() => _IncomingTransfersListState();
// }

// class _IncomingTransfersListState extends State<_IncomingTransfersList> {
//   @override
//   void didUpdateWidget(covariant _IncomingTransfersList oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.warehouseId != oldWidget.warehouseId && widget.warehouseId != null) {
//       context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.warehouseId == null) {
//        return _buildSelectPrompt();
//     }

//     return BlocBuilder<TransfersCubit, TransfersState>(
//       // Only rebuild for Incoming states
//       buildWhen: (p, c) => c is GetIncomingSuccess || c is GetIncomingLoading || c is GetIncomingError,
//       builder: (context, state) {
//         if (state is GetIncomingLoading) return const CustomLoadingShimmer();
        
//         if (state is GetIncomingSuccess) {
//            if (state.transfers.isEmpty) return const _EmptyTransfers();
//            return RefreshIndicator(
//              onRefresh: () async => context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!),
//              child: ListView.separated(
//                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
//                itemCount: state.transfers.length,
//                separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
//                itemBuilder: (context, i) => TransferCard(
//                  transfer: state.transfers[i], 
//                  type: TransferType.incoming,
//                  currentWarehouseId: widget.warehouseId!,
//                ),
//              ),
//            );
//         }
//         // If we switched tabs but haven't fetched yet
//         if (state is TransfersInitial) {
//            context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!);
//            return const CustomLoadingShimmer();
//         }
//         return SizedBox(); 
//       },
//     );
//   }
// }

// class _OutgoingTransfersList extends StatefulWidget {
//   final String? warehouseId;
//   const _OutgoingTransfersList({this.warehouseId});

//   @override
//   State<_OutgoingTransfersList> createState() => _OutgoingTransfersListState();
// }

// class _OutgoingTransfersListState extends State<_OutgoingTransfersList> {
//   @override
//   void didUpdateWidget(covariant _OutgoingTransfersList oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.warehouseId != oldWidget.warehouseId && widget.warehouseId != null) {
//       context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.warehouseId == null) {
//        return _buildSelectPrompt();
//     }

//     return BlocBuilder<TransfersCubit, TransfersState>(
//       buildWhen: (p, c) => c is GetOutgoingSuccess || c is GetOutgoingLoading || c is GetOutgoingError,
//       builder: (context, state) {
//         if (state is GetOutgoingLoading) return const CustomLoadingShimmer();
        
//         if (state is GetOutgoingSuccess) {
//            if (state.transfers.isEmpty) return const _EmptyTransfers();
//            return RefreshIndicator(
//              onRefresh: () async => context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!),
//              child: ListView.separated(
//                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
//                itemCount: state.transfers.length,
//                separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
//                itemBuilder: (context, i) => TransferCard(
//                  transfer: state.transfers[i], 
//                  type: TransferType.outgoing,
//                  currentWarehouseId: widget.warehouseId!,
//                ),
//              ),
//            );
//         }
//         if (state is TransfersInitial) {
//            context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!);
//            return const CustomLoadingShimmer();
//         }
//         return SizedBox();
//       },
//     );
//   }
// }

// // History Tab and Helpers remain mostly the same
// class _AllTransfersList extends StatefulWidget {
//   const _AllTransfersList();
//   @override
//   State<_AllTransfersList> createState() => _AllTransfersListState();
// }

// class _AllTransfersListState extends State<_AllTransfersList> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     context.read<TransfersCubit>().getAllTransfers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return BlocBuilder<TransfersCubit, TransfersState>(
//       buildWhen: (p, c) => c is GetTransfersSuccess || c is GetTransfersLoading || c is GetTransfersError,
//       builder: (context, state) {
//         if (state is GetTransfersLoading) return const CustomLoadingShimmer();
//         if (state is GetTransfersSuccess) {
//            if (state.transfers.isEmpty) return const _EmptyTransfers();
//            return RefreshIndicator(
//              onRefresh: () async => context.read<TransfersCubit>().getAllTransfers(),
//              child: ListView.separated(
//                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
//                itemCount: state.transfers.length,
//                separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
//                itemBuilder: (context, i) => TransferCard(
//                  transfer: state.transfers[i], 
//                  type: TransferType.history,
//                  currentWarehouseId: "",
//                ),
//              ),
//            );
//         }
//         return SizedBox();
//       },
//     );
//   }
// }

// // Helpers
// Widget _buildSelectPrompt() {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.touch_app, size: ResponsiveUI.iconSize(context, 64), color: Colors.grey[400]),
//         SizedBox(height: ResponsiveUI.value(context, 16)),
//         Text(LocaleKeys.select_warehouse.tr(), style: TextStyle(color: Colors.grey[600])),
//       ],
//     ),
//   );
// }

// class _EmptyTransfers extends StatelessWidget {
//   const _EmptyTransfers();
//   @override
//   Widget build(BuildContext context) {
//     return CustomEmptyState(
//       icon: Icons.swap_horiz_rounded,
//       title: LocaleKeys.no_transfers.tr(),
//       message: LocaleKeys.no_transfers_message.tr(),
//       onRefresh: () async {},
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/transfer/cubit/transfers_cubit.dart';
import 'package:GoSystem/features/admin/transfer/presentation/widgets/create_transfer_dialog.dart';
import 'package:GoSystem/features/admin/transfer/presentation/widgets/transfer_card.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransfersView();
  }
}

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  State<TransfersView> createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Store separate warehouse IDs for each tab
  String? _selectedIncomingWarehouseId;
  String? _selectedOutgoingWarehouseId;
  
  bool _showWarehouseSelector = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _tabController.addListener(() {
      setState(() {
        _showWarehouseSelector = _tabController.index != 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.transfers.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CreateTransferDialog(),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(context),
          
          if (_showWarehouseSelector) 
            _buildWarehouseFilter(context),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _AllTransfersList(),
                // Tab 1: Incoming
                _IncomingTransfersList(
                  warehouseId: _selectedIncomingWarehouseId,
                  onWarehouseSelected: (id) {
                    setState(() {
                      _selectedIncomingWarehouseId = id;
                    });
                  },
                ),
                
                // Tab 2: Outgoing
                _OutgoingTransfersList(
                  warehouseId: _selectedOutgoingWarehouseId,
                  onWarehouseSelected: (id) {
                    setState(() {
                      _selectedOutgoingWarehouseId = id;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.darkGray,
        indicatorColor: AppColors.primaryBlue,
        tabs: [
          Tab(text: LocaleKeys.all_transfers.tr(), icon: Icon(Icons.transfer_within_a_station)),
          Tab(text: LocaleKeys.incoming.tr(), icon: Icon(Icons.move_to_inbox)),
          Tab(text: LocaleKeys.outgoing.tr(), icon: Icon(Icons.outbox)),
        ],
      ),
    );
  }

  Widget _buildWarehouseFilter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 12),
      ),
      color: Colors.grey[50],
      child: BlocBuilder<WareHouseCubit, WarehousesState>(
        builder: (context, state) {
          if (state is WarehousesLoading) {
            return const LinearProgressIndicator();
          } 

          if (state is WarehousesLoaded) {
            final warehouses = state.warehouses;
            
            // Determine which warehouse ID to use based on current tab
            final currentTabId = _tabController.index;
            String? currentWarehouseId;
            if (currentTabId == 1) {
              currentWarehouseId = _selectedIncomingWarehouseId;
            } else if (currentTabId == 2) {
              currentWarehouseId = _selectedOutgoingWarehouseId;
            }

            // Reset if warehouse no longer exists
            if (currentWarehouseId != null &&
                !warehouses.any((w) => w.id == currentWarehouseId)) {
              currentWarehouseId = null;
              if (currentTabId == 1) {
                _selectedIncomingWarehouseId = null;
              } else if (currentTabId == 2) {
                _selectedOutgoingWarehouseId = null;
              }
            }

            String? selectedName;
            if (currentWarehouseId != null) {
              try {
                selectedName = warehouses
                    .firstWhere((w) => w.id == currentWarehouseId)
                    .name;
              } catch (e) {
                currentWarehouseId = null;
                if (currentTabId == 1) {
                  _selectedIncomingWarehouseId = null;
                } else if (currentTabId == 2) {
                  _selectedOutgoingWarehouseId = null;
                }
              }
            }

            return buildDropdownField<String>(
              context,
              value: selectedName, 
              items: warehouses.map((e) => e.name).toList(),
              hint: LocaleKeys.select_warehouse.tr(),
              label: "Filter by Warehouse",
              icon: Icons.store,
              onChanged: (nameValue) {
                if (nameValue == null) return;
                
                final selectedWarehouse = warehouses.firstWhere((e) => e.name == nameValue);
                final selectedId = selectedWarehouse.id;
                
                // Call the callback to notify the specific tab
                final currentTab = _tabController.index;
                if (currentTab == 1) {
                  context.read<_IncomingTransfersListState?>()?.onWarehouseSelected(selectedId);
                } else if (currentTab == 2) {
                  context.read<_OutgoingTransfersListState?>()?.onWarehouseSelected(selectedId);
                }
                
                // Also update local state
                setState(() {
                  if (currentTab == 1) {
                    _selectedIncomingWarehouseId = selectedId;
                  } else if (currentTab == 2) {
                    _selectedOutgoingWarehouseId = selectedId;
                  }
                });
              },
              itemLabel: (name) => name,
            );
          }
          
          if (state is WarehousesError) {
            return Text(state.message, style: TextStyle(color: Colors.red));
          }

          return SizedBox();
        },
      ),
    );
  }
}

// --- Modified Incoming Tab with callback ---

class _IncomingTransfersList extends StatefulWidget {
  final String? warehouseId;
  final Function(String)? onWarehouseSelected;
  const _IncomingTransfersList({this.warehouseId, this.onWarehouseSelected});

  @override
  State<_IncomingTransfersList> createState() => _IncomingTransfersListState();
}

class _IncomingTransfersListState extends State<_IncomingTransfersList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  void didUpdateWidget(covariant _IncomingTransfersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.warehouseId != oldWidget.warehouseId && widget.warehouseId != null) {
      context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!);
    } 
  }

  void onWarehouseSelected(String id) {
    if (widget.onWarehouseSelected != null) {
      widget.onWarehouseSelected!(id);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load transfers if warehouseId is already set
    if (widget.warehouseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.warehouseId == null) {
      return _buildSelectPrompt();
    }

    return BlocBuilder<TransfersCubit, TransfersState>(
      // Only rebuild for Incoming states
      buildWhen: (p, c) => c is GetIncomingSuccess || 
                          c is GetIncomingLoading || 
                          c is GetIncomingError,
                       
      builder: (context, state) {
        if (state is GetIncomingLoading) return const CustomLoadingShimmer();
        
        if (state is GetIncomingSuccess) {
          if (state.transfers.isEmpty) return const _EmptyTransfers();
          return RefreshIndicator(
            onRefresh: () async => context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!),
            child: ListView.separated(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              itemCount: state.transfers.length,
              separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
              itemBuilder: (context, i) => TransferCard(
                transfer: state.transfers[i], 
                type: TransferType.incoming,
                currentWarehouseId: widget.warehouseId!,
              ),
            ),
          );
        }
       
        
        // If we switched tabs but haven't fetched yet
        if (state is TransfersInitial || state is GetOutgoingSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.warehouseId != null) {
              context.read<TransfersCubit>().getIncomingTransfers(widget.warehouseId!);
            }
          });
          return widget.warehouseId != null ? const CustomLoadingShimmer() : _buildSelectPrompt();
        }
        
        return SizedBox(); 
      },
    );
  }
}

// --- Modified Outgoing Tab with callback ---

class _OutgoingTransfersList extends StatefulWidget {
  final String? warehouseId;
  final Function(String)? onWarehouseSelected;
  const _OutgoingTransfersList({this.warehouseId, this.onWarehouseSelected});

  @override
  State<_OutgoingTransfersList> createState() => _OutgoingTransfersListState();
}

class _OutgoingTransfersListState extends State<_OutgoingTransfersList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  void didUpdateWidget(covariant _OutgoingTransfersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.warehouseId != oldWidget.warehouseId && widget.warehouseId != null) {
      context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!);
    } 
  }

  void onWarehouseSelected(String id) {
    if (widget.onWarehouseSelected != null) {
      widget.onWarehouseSelected!(id);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load transfers if warehouseId is already set
    if (widget.warehouseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (widget.warehouseId == null) {
      return _buildSelectPrompt();
    }

    return BlocBuilder<TransfersCubit, TransfersState>(
      buildWhen: (p, c) => c is GetOutgoingSuccess || 
                          c is GetOutgoingLoading || 
                          c is GetOutgoingError,
                        
      builder: (context, state) {
        if (state is GetOutgoingLoading) return const CustomLoadingShimmer();
        
        if (state is GetOutgoingSuccess) {
          if (state.transfers.isEmpty) return const _EmptyTransfers();
          return RefreshIndicator(
            onRefresh: () async => context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!),
            child: ListView.separated(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              itemCount: state.transfers.length,
              separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
              itemBuilder: (context, i) => TransferCard(
                transfer: state.transfers[i], 
                type: TransferType.outgoing,
                currentWarehouseId: widget.warehouseId!,
              ),
            ),
          );
        }

        if (state is TransfersInitial || state is GetIncomingSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.warehouseId != null) {
              context.read<TransfersCubit>().getOutgoingTransfers(widget.warehouseId!);
            }
          });
          return widget.warehouseId != null ? const CustomLoadingShimmer() : _buildSelectPrompt();
        }
        
        return SizedBox();
      },
    );
  }
}


// History Tab
class _AllTransfersList extends StatefulWidget {
  const _AllTransfersList();
  @override
  State<_AllTransfersList> createState() => _AllTransfersListState();
}

class _AllTransfersListState extends State<_AllTransfersList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransfersCubit>().getAllTransfers();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<TransfersCubit, TransfersState>(
      buildWhen: (p, c) => c is GetTransfersSuccess || c is GetTransfersLoading || c is GetTransfersError,
      builder: (context, state) {
        if (state is GetTransfersLoading) return const CustomLoadingShimmer();
        if (state is GetTransfersSuccess) {
          if (state.transfers.isEmpty) return const _EmptyTransfers();
          return RefreshIndicator(
            onRefresh: () async => context.read<TransfersCubit>().getAllTransfers(),
            child: ListView.separated(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              itemCount: state.transfers.length,
              separatorBuilder: (c, i) => SizedBox(height: ResponsiveUI.spacing(context, 12)),
              itemBuilder: (context, i) => TransferCard(
                transfer: state.transfers[i], 
                type: TransferType.history,
                currentWarehouseId: "",
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}

// Helpers
Widget _buildSelectPrompt() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app, size: 64, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text(LocaleKeys.select_warehouse.tr(), style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  );
}

class _EmptyTransfers extends StatelessWidget {
  const _EmptyTransfers();
  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      icon: Icons.swap_horiz_rounded,
      title: LocaleKeys.no_transfers.tr(),
      message: LocaleKeys.no_transfers_message.tr(),
      onRefresh: () async {},
    );
  }
}
