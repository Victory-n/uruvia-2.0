import 'dart:isolate';
import '../models/finance_event.dart';

class EventsStats {
  final int totalEvents;
  final double totalTarget;
  final double totalSaved;
  final int completedCount;

  const EventsStats({
    required this.totalEvents,
    required this.totalTarget,
    required this.totalSaved,
    required this.completedCount,
  });

  static const EventsStats empty = EventsStats(
    totalEvents: 0,
    totalTarget: 0.0,
    totalSaved: 0.0,
    completedCount: 0,
  );
}

class EventsService {
  static final EventsService _instance = EventsService._internal();
  static EventsService get instance => _instance;
  EventsService._internal();

  List<FinanceEvent> _cachedEvents = [];
  bool _initialized = false;

  /// Load events and offload initial list processing to Isolate (Rule 1, Rule 3)
  Future<List<FinanceEvent>> getEvents() async {
    if (!_initialized) {
      final initialMaps = FinanceEvent.initialEvents.map((e) => e.toMap()).toList();

      // Rule 1: Offload parsing and data generation to background Isolate
      _cachedEvents = await Isolate.run(() {
        return initialMaps.map((m) => FinanceEvent.fromMap(m)).toList();
      });
      _initialized = true;
    }
    return List.unmodifiable(_cachedEvents);
  }

  /// Calculate aggregate financial statistics in background Isolate (Rule 1)
  Future<EventsStats> calculateStats(List<FinanceEvent> events) async {
    if (events.isEmpty) return EventsStats.empty;

    final maps = events.map((e) => e.toMap()).toList();

    return await Isolate.run(() {
      int totalEvents = maps.length;
      double totalTarget = 0.0;
      double totalSaved = 0.0;
      int completed = 0;

      for (final m in maps) {
        final target = (m['target_amount'] as num?)?.toDouble() ?? 0.0;
        final current = (m['current_amount'] as num?)?.toDouble() ?? 0.0;
        totalTarget += target;
        totalSaved += current;
        if (current >= target && target > 0) {
          completed++;
        }
      }

      return EventsStats(
        totalEvents: totalEvents,
        totalTarget: totalTarget,
        totalSaved: totalSaved,
        completedCount: completed,
      );
    });
  }

  /// Filter and search events off the UI thread via Isolate (Rule 1)
  Future<List<FinanceEvent>> filterEvents({
    required List<FinanceEvent> source,
    required String query,
    required String category,
  }) async {
    final maps = source.map((e) => e.toMap()).toList();

    return await Isolate.run(() {
      final q = query.trim().toLowerCase();
      final cat = category.trim().toLowerCase();

      return maps
          .map((m) => FinanceEvent.fromMap(m))
          .where((event) {
            // Category filter
            if (cat != 'all') {
              final label = event.type.label.toLowerCase();
              final categoryName = event.category.toLowerCase();
              if (label != cat && categoryName != cat) {
                return false;
              }
            }

            // Search query filter
            if (q.isNotEmpty) {
              final title = event.title.toLowerCase();
              final description = event.description.toLowerCase();
              if (!title.contains(q) && !description.contains(q)) {
                return false;
              }
            }

            return true;
          })
          .toList();
    });
  }

  /// Add new event to local cache (Rule 3)
  void addEvent(FinanceEvent newEvent) {
    _cachedEvents.insert(0, newEvent);
  }

  /// Contribute funds to an existing event
  FinanceEvent? contribute(String eventId, double amount) {
    final index = _cachedEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final current = _cachedEvents[index];
      final updated = current.copyWith(
        currentAmount: current.currentAmount + amount,
      );
      _cachedEvents[index] = updated;
      return updated;
    }
    return null;
  }
}
