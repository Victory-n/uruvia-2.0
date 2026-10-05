import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../individual_account/sidebar/app_sidebar.dart';
import '../../../widgets/app_text.dart';
import '../group savings/screens/ajo_details_screen.dart';
import '../models/finance_event.dart';
import '../services/events_service.dart';
import '../widgets/contribute_dialog.dart';
import '../widgets/create_event_sheet.dart';
import '../widgets/event_card.dart';
import '../widgets/events_empty_state.dart';
import '../widgets/events_filter_chips.dart';
import '../widgets/events_header_card.dart';
import '../widgets/welcome_events_sheet.dart';

class EventsScreen extends StatefulWidget {
  final bool showWelcomeInitially;

  const EventsScreen({super.key, this.showWelcomeInitially = true});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventsService _eventsService = EventsService.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<FinanceEvent> _allEvents = [];
  List<FinanceEvent> _filteredEvents = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();

    if (widget.showWelcomeInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeSheet();
      });
    }
  }

  /// Fetch events and filter them off-thread via Isolate (Rule 1, Rule 3)
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _eventsService.getEvents();
    if (mounted) {
      setState(() {
        _allEvents = events;
      });
      await _applyFilters();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Offload filtering to background Isolate (Rule 1)
  Future<void> _applyFilters() async {
    final filtered = await _eventsService.filterEvents(
      source: _allEvents,
      query: '',
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _filteredEvents = filtered;
      });
    }
  }

  void _showWelcomeSheet() {
    WelcomeEventsSheet.show(context, onExplore: () {});
  }

  void _openCreateEventSheet() {
    CreateEventSheet.show(context, (newEvent) async {
      _eventsService.addEvent(newEvent);
      final events = await _eventsService.getEvents();
      if (mounted) {
        setState(() {
          _allEvents = events;
        });
        await _applyFilters();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.paragraph(
                'Created "${newEvent.title}" event!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0060E6),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _showContributeDialog(FinanceEvent event) {
    ContributeDialog.show(
      context,
      event: event,
      onContributed: (amount) async {
        _eventsService.contribute(event.id, amount);
        final events = await _eventsService.getEvents();
        if (mounted) {
          setState(() {
            _allEvents = events;
          });
          await _applyFilters();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText.paragraph(
                  'Added \$${amount.toStringAsFixed(0)} to ${event.title}!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppSidebar(activeItem: 'Events'),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.bars,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const AppText.subtitle(
          'Finance Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.circleInfo,
              color: Color(0xFF0066DB),
              size: 20,
            ),
            onPressed: _showWelcomeSheet,
            tooltip: 'Welcome Info',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Events & Goals Hub Card (extracted per Rule 5)
              EventsHeaderCard(onInfoPressed: _showWelcomeSheet),

              const SizedBox(height: 24),

              // Filter Chips (extracted per Rule 5, AppText per Rule 7)
              EventsFilterChips(
                selectedCategory: _selectedCategory,
                onSelected: _onCategorySelected,
              ),

              const SizedBox(height: 18),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.custom(
                    'Active Milestones (${_filteredEvents.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openCreateEventSheet,
                    icon: const FaIcon(
                      FontAwesomeIcons.plus,
                      size: 13,
                      color: Color(0xFF0060E6),
                    ),
                    label: const AppText.button(
                      'New Event',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0060E6),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Events List or Empty State
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredEvents.isEmpty)
                EventsEmptyState(onCreatePressed: _openCreateEventSheet)
              else
                ..._filteredEvents.map(
                  (event) => EventCard(
                    event: event,
                    onTap: () {
                      if (event.type == EventType.groupSavings) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AjoDetailsScreen(groupId: 'ajo-1'),
                          ),
                        );
                      } else {
                        _showContributeDialog(event);
                      }
                    },
                    onAddFunds: () => _showContributeDialog(event),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEventSheet,
        backgroundColor: const Color(0xFF0060E6),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
        label: const AppText.button(
          'Create Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
