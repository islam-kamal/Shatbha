import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import 'project_os_models.dart';

/// Single API surface for Project-OS feature.
/// Uses the Dio instance from GetIt (bearer token pre-attached).
class ProjectOsApi {
  ProjectOsApi(this._dio);
  final Dio _dio;

  // ── Command Center ─────────────────────────────────────────────────────────

  Future<List<ActionRequiredItem>> commandCenter() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/command-center');
      return jsonList(res.data, ActionRequiredItem.fromJson);
    });
  }

  // ── Leads ──────────────────────────────────────────────────────────────────

  Future<List<Lead>> listLeads() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/leads');
      return jsonList(res.data, Lead.fromJson);
    });
  }

  Future<Lead> getLead(int id) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/leads/$id');
      return Lead.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Lead> createLead(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/leads', data: body);
      return Lead.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<Lead> updateLead(int id, Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.put<Map<String, dynamic>>('/leads/$id', data: body);
      return Lead.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  /// POST /leads/{id}/win — creates Party + Project + Contract + installments
  Future<Map<String, dynamic>> winLead(int id, Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/leads/$id/win', data: body);
      return res.data!['data'] as Map<String, dynamic>;
    });
  }

  // ── Site Visits ────────────────────────────────────────────────────────────

  Future<List<SiteVisit>> listSiteVisits(int leadId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/site-visits?lead_id=$leadId');
      return jsonList(res.data, SiteVisit.fromJson);
    });
  }

  Future<SiteVisit> createSiteVisit(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/site-visits', data: body);
      return SiteVisit.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Proposals ─────────────────────────────────────────────────────────────

  Future<List<Proposal>> listProposals(int leadId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/proposals?lead_id=$leadId');
      return jsonList(res.data, Proposal.fromJson);
    });
  }

  Future<Proposal> createProposal(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/proposals', data: body);
      return Proposal.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Contracts ─────────────────────────────────────────────────────────────

  Future<List<Contract>> listContracts(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/contracts?project_id=$projectId');
      return jsonList(res.data, Contract.fromJson);
    });
  }

  Future<Contract> createContract(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/contracts', data: body);
      return Contract.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Payment Installments ──────────────────────────────────────────────────

  Future<List<PaymentInstallment>> listInstallments(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/payment-installments?project_id=$projectId',
      );
      return jsonList(res.data, PaymentInstallment.fromJson);
    });
  }

  Future<PaymentInstallment> markPaid(int id) {
    return guardDio(() async {
      final res = await _dio
          .post<Map<String, dynamic>>('/payment-installments/$id/mark-paid');
      return PaymentInstallment.fromJson(
          res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Design Versions ───────────────────────────────────────────────────────

  Future<List<DesignVersion>> listDesignVersions(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/design-versions?project_id=$projectId');
      return jsonList(res.data, DesignVersion.fromJson);
    });
  }

  // ── Client Selections ─────────────────────────────────────────────────────

  Future<List<ClientSelection>> listSelections(int projectId) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/client-selections?project_id=$projectId',
      );
      return jsonList(res.data, ClientSelection.fromJson);
    });
  }

  Future<ClientSelection> approveSelection(int id) {
    return guardDio(() async {
      final res = await _dio
          .post<Map<String, dynamic>>('/client-selections/$id/approve');
      return ClientSelection.fromJson(
          res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ClientSelection> createSelection(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/client-selections',
        data: body,
      );
      return ClientSelection.fromJson(
          res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Change Orders ─────────────────────────────────────────────────────────

  Future<List<ChangeOrder>> listChangeOrders(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/change-orders?project_id=$projectId');
      return jsonList(res.data, ChangeOrder.fromJson);
    });
  }

  Future<ChangeOrder> createChangeOrder(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/change-orders', data: body);
      return ChangeOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<ChangeOrder> approveChangeOrder(int id) {
    return guardDio(() async {
      final res = await _dio
          .post<Map<String, dynamic>>('/change-orders/$id/approve');
      return ChangeOrder.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Daily Site Logs ───────────────────────────────────────────────────────

  Future<List<DailySiteLog>> listDailyLogs(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/daily-site-logs?project_id=$projectId');
      return jsonList(res.data, DailySiteLog.fromJson);
    });
  }

  Future<DailySiteLog> createDailyLog(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/daily-site-logs', data: body);
      return DailySiteLog.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Warranty Claims ───────────────────────────────────────────────────────

  Future<List<WarrantyClaim>> listWarrantyClaims(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/warranty-claims?project_id=$projectId');
      return jsonList(res.data, WarrantyClaim.fromJson);
    });
  }

  Future<WarrantyClaim> createWarrantyClaim(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio
          .post<Map<String, dynamic>>('/warranty-claims', data: body);
      return WarrantyClaim.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<WarrantyClaim> resolveWarrantyClaim(int id) {
    return guardDio(() async {
      final res = await _dio
          .post<Map<String, dynamic>>('/warranty-claims/$id/resolve');
      return WarrantyClaim.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Project Lifecycle ─────────────────────────────────────────────────────

  Future<ProjectLifecycle> getLifecycle(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/projects/$projectId/lifecycle');
      return ProjectLifecycle.fromJson(
          res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Project Financials ────────────────────────────────────────────────────

  Future<ProjectFinancials> getFinancials(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/projects/$projectId/financials');
      return ProjectFinancials.fromJson(
          res.data!['data'] as Map<String, dynamic>);
    });
  }

  // ── Audit ─────────────────────────────────────────────────────────────────

  Future<List<AuditEvent>> listAudit(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/projects/$projectId/audit');
      return jsonList(res.data, AuditEvent.fromJson);
    });
  }

  // ── Client Hub ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> clientHub(int projectId) {
    return guardDio(() async {
      final res = await _dio
          .get<Map<String, dynamic>>('/projects/$projectId/client-hub');
      return res.data!['data'] as Map<String, dynamic>;
    });
  }
}
