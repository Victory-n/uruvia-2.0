import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/support_models.dart';

abstract class SupportRepository {
  Future<List<SupportTicket>> tickets();
  Future<SupportTicket?> ticket(String id);
  Future<List<SupportMessage>> messages(String ticketId);
  Future<String> createTicket({required String? accountId, required String category, required String description});
  Future<void> reply(String ticketId, String body);
  Future<void> resolve(String ticketId);
}

class SupabaseSupportRepository implements SupportRepository {
  const SupabaseSupportRepository();

  static const _cols = 'id, reference, category, description, status, created_at, updated_at';

  @override
  Future<List<SupportTicket>> tickets() async {
    final rows = await supabase.from('support_tickets').select(_cols).order('created_at', ascending: false) as List;
    return [for (final r in rows) SupportTicket.fromRow(r as Map<String, dynamic>)];
  }

  @override
  Future<SupportTicket?> ticket(String id) async {
    final r = await supabase.from('support_tickets').select(_cols).eq('id', id).maybeSingle();
    return r == null ? null : SupportTicket.fromRow(r);
  }

  @override
  Future<List<SupportMessage>> messages(String ticketId) async {
    final rows = await supabase
        .from('support_messages')
        .select('id, body, is_staff, created_at')
        .eq('ticket_id', ticketId)
        .order('created_at') as List;
    return [for (final r in rows) SupportMessage.fromRow(r as Map<String, dynamic>)];
  }

  @override
  Future<String> createTicket({required String? accountId, required String category, required String description}) async {
    final r = await supabase
        .from('support_tickets')
        .insert({'account_id': accountId, 'category': category, 'description': description.trim()})
        .select('id')
        .single();
    return r['id'] as String;
  }

  @override
  Future<void> reply(String ticketId, String body) async {
    await supabase.from('support_messages').insert({'ticket_id': ticketId, 'body': body.trim()});
  }

  @override
  Future<void> resolve(String ticketId) async {
    await supabase.from('support_tickets').update({'status': 'resolved'}).eq('id', ticketId);
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) => const SupabaseSupportRepository());
