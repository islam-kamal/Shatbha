// ignore_for_file: public_member_api_docs
import '../../../../core/utils/json.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lead
// ─────────────────────────────────────────────────────────────────────────────

class Lead {
  const Lead({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.source,
    this.status = 'new',
    this.notes,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? source;
  final String status;
  final String? notes;
  final String? assignedTo;
  final String? createdAt;
  final String? updatedAt;

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        source: json['source'] as String?,
        status: json['status'] as String? ?? 'new',
        notes: json['notes'] as String?,
        assignedTo: json['assigned_to'] as String?,
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SiteVisit
// ─────────────────────────────────────────────────────────────────────────────

class SiteVisit {
  const SiteVisit({
    required this.id,
    required this.leadId,
    this.scheduledAt,
    this.notes,
    this.status = 'scheduled',
    this.createdAt,
  });

  final int id;
  final int leadId;
  final String? scheduledAt;
  final String? notes;
  final String status;
  final String? createdAt;

  factory SiteVisit.fromJson(Map<String, dynamic> json) => SiteVisit(
        id: json['id'] as int,
        leadId: json['lead_id'] as int? ?? 0,
        scheduledAt: json['scheduled_at']?.toString(),
        notes: json['notes'] as String?,
        status: json['status'] as String? ?? 'scheduled',
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Proposal
// ─────────────────────────────────────────────────────────────────────────────

class Proposal {
  const Proposal({
    required this.id,
    required this.leadId,
    this.totalAmount = '0.00',
    this.status = 'draft',
    this.sentAt,
    this.expiresAt,
    this.notes,
    this.createdAt,
  });

  final int id;
  final int leadId;
  final String totalAmount;
  final String status;
  final String? sentAt;
  final String? expiresAt;
  final String? notes;
  final String? createdAt;

  factory Proposal.fromJson(Map<String, dynamic> json) => Proposal(
        id: json['id'] as int,
        leadId: json['lead_id'] as int? ?? 0,
        totalAmount: jsonMoney(json['total_amount'] ?? json['amount']),
        status: json['status'] as String? ?? 'draft',
        sentAt: json['sent_at']?.toString(),
        expiresAt: json['expires_at']?.toString(),
        notes: json['notes'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Contract
// ─────────────────────────────────────────────────────────────────────────────

class Contract {
  const Contract({
    required this.id,
    required this.projectId,
    this.contractValue = '0.00',
    this.status = 'draft',
    this.signedAt,
    this.startDate,
    this.endDate,
    this.notes,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String contractValue;
  final String status;
  final String? signedAt;
  final String? startDate;
  final String? endDate;
  final String? notes;
  final String? createdAt;

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        contractValue: jsonMoney(json['contract_value'] ?? json['value']),
        status: json['status'] as String? ?? 'draft',
        signedAt: json['signed_at']?.toString(),
        startDate: json['start_date']?.toString(),
        endDate: json['end_date']?.toString(),
        notes: json['notes'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PaymentInstallment
// ─────────────────────────────────────────────────────────────────────────────

class PaymentInstallment {
  const PaymentInstallment({
    required this.id,
    required this.projectId,
    this.amount = '0.00',
    this.dueDate,
    this.paidAt,
    this.status = 'pending',
    this.label,
    this.notes,
  });

  final int id;
  final int projectId;
  final String amount;
  final String? dueDate;
  final String? paidAt;
  final String status;
  final String? label;
  final String? notes;

  factory PaymentInstallment.fromJson(Map<String, dynamic> json) =>
      PaymentInstallment(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        amount: jsonMoney(json['amount']),
        dueDate: json['due_date']?.toString(),
        paidAt: json['paid_at']?.toString(),
        status: json['status'] as String? ?? 'pending',
        label: json['label'] as String?,
        notes: json['notes'] as String?,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DesignVersion
// ─────────────────────────────────────────────────────────────────────────────

class DesignVersion {
  const DesignVersion({
    required this.id,
    required this.projectId,
    required this.versionNumber,
    this.status = 'draft',
    this.notes,
    this.approvedAt,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final int versionNumber;
  final String status;
  final String? notes;
  final String? approvedAt;
  final String? createdAt;

  factory DesignVersion.fromJson(Map<String, dynamic> json) => DesignVersion(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        versionNumber: json['version_number'] as int? ?? 1,
        status: json['status'] as String? ?? 'draft',
        notes: json['notes'] as String?,
        approvedAt: json['approved_at']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ClientSelection
// ─────────────────────────────────────────────────────────────────────────────

class ClientSelection {
  const ClientSelection({
    required this.id,
    required this.projectId,
    required this.category,
    this.itemName,
    this.status = 'pending',
    this.clientNote,
    this.approvedAt,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String category;
  final String? itemName;
  final String status;
  final String? clientNote;
  final String? approvedAt;
  final String? createdAt;

  factory ClientSelection.fromJson(Map<String, dynamic> json) =>
      ClientSelection(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        category: json['category'] as String? ?? '',
        itemName: json['item_name'] as String?,
        status: json['status'] as String? ?? 'pending',
        clientNote: json['client_note'] as String?,
        approvedAt: json['approved_at']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ChangeOrder
// ─────────────────────────────────────────────────────────────────────────────

class ChangeOrder {
  const ChangeOrder({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.amount = '0.00',
    this.status = 'pending',
    this.requestedAt,
    this.approvedAt,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String amount;
  final String status;
  final String? requestedAt;
  final String? approvedAt;
  final String? createdAt;

  factory ChangeOrder.fromJson(Map<String, dynamic> json) => ChangeOrder(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        amount: jsonMoney(json['amount']),
        status: json['status'] as String? ?? 'pending',
        requestedAt: json['requested_at']?.toString(),
        approvedAt: json['approved_at']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DailySiteLog
// ─────────────────────────────────────────────────────────────────────────────

class DailySiteLog {
  const DailySiteLog({
    required this.id,
    required this.projectId,
    required this.logDate,
    this.summary,
    this.weatherCondition,
    this.workersOnSite,
    this.progressNotes,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String logDate;
  final String? summary;
  final String? weatherCondition;
  final int? workersOnSite;
  final String? progressNotes;
  final String? createdAt;

  factory DailySiteLog.fromJson(Map<String, dynamic> json) => DailySiteLog(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        logDate: json['log_date']?.toString() ?? '',
        summary: json['summary'] as String?,
        weatherCondition: json['weather_condition'] as String?,
        workersOnSite: json['workers_on_site'] as int?,
        progressNotes: json['progress_notes'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// WarrantyClaim
// ─────────────────────────────────────────────────────────────────────────────

class WarrantyClaim {
  const WarrantyClaim({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = 'open',
    this.resolvedAt,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String title;
  final String? description;
  final String status;
  final String? resolvedAt;
  final String? createdAt;

  factory WarrantyClaim.fromJson(Map<String, dynamic> json) => WarrantyClaim(
        id: json['id'] as int,
        projectId: json['project_id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'open',
        resolvedAt: json['resolved_at']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ActionRequiredItem — from command center
// ─────────────────────────────────────────────────────────────────────────────

class ActionRequiredItem {
  const ActionRequiredItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.route,
    this.priority = 'normal',
    this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final String? route;
  final String priority;
  final String? createdAt;

  factory ActionRequiredItem.fromJson(Map<String, dynamic> json) =>
      ActionRequiredItem(
        id: json['id']?.toString() ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        route: json['route'] as String?,
        priority: json['priority'] as String? ?? 'normal',
        createdAt: json['created_at']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectLifecycle
// ─────────────────────────────────────────────────────────────────────────────

class ProjectLifecycle {
  const ProjectLifecycle({
    required this.projectId,
    this.lifecycleStatus = 'planning',
    this.executionUnlocked = false,
    this.nextAction,
    this.nextActionRoute,
    this.designProgress = 0,
    this.procurementProgress = 0,
    this.executionProgress = 0,
    this.financeProgress = 0,
  });

  final int projectId;
  final String lifecycleStatus;
  final bool executionUnlocked;
  final String? nextAction;
  final String? nextActionRoute;
  final int designProgress;
  final int procurementProgress;
  final int executionProgress;
  final int financeProgress;

  factory ProjectLifecycle.fromJson(Map<String, dynamic> json) =>
      ProjectLifecycle(
        projectId: json['project_id'] as int? ?? 0,
        lifecycleStatus: json['lifecycle_status'] as String? ?? 'planning',
        executionUnlocked: json['execution_unlocked'] as bool? ?? false,
        nextAction: json['next_action'] as String?,
        nextActionRoute: json['next_action_route'] as String?,
        designProgress: (json['design_progress'] as num?)?.round() ?? 0,
        procurementProgress:
            (json['procurement_progress'] as num?)?.round() ?? 0,
        executionProgress: (json['execution_progress'] as num?)?.round() ?? 0,
        financeProgress: (json['finance_progress'] as num?)?.round() ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProjectFinancials
// ─────────────────────────────────────────────────────────────────────────────

class ProjectFinancials {
  const ProjectFinancials({
    required this.projectId,
    this.contractValue = '0.00',
    this.totalPaid = '0.00',
    this.totalDue = '0.00',
    this.totalChangeOrders = '0.00',
    this.totalCost = '0.00',
    this.profitMargin,
  });

  final int projectId;
  final String contractValue;
  final String totalPaid;
  final String totalDue;
  final String totalChangeOrders;
  final String totalCost;
  final String? profitMargin;

  factory ProjectFinancials.fromJson(Map<String, dynamic> json) =>
      ProjectFinancials(
        projectId: json['project_id'] as int? ?? 0,
        contractValue: jsonMoney(json['contract_value']),
        totalPaid: jsonMoney(json['total_paid']),
        totalDue: jsonMoney(json['total_due']),
        totalChangeOrders: jsonMoney(json['total_change_orders']),
        totalCost: jsonMoney(json['total_cost']),
        profitMargin: json['profit_margin']?.toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AuditEvent
// ─────────────────────────────────────────────────────────────────────────────

class AuditEvent {
  const AuditEvent({
    required this.id,
    this.event,
    this.description,
    this.causedBy,
    this.createdAt,
  });

  final int id;
  final String? event;
  final String? description;
  final String? causedBy;
  final String? createdAt;

  factory AuditEvent.fromJson(Map<String, dynamic> json) => AuditEvent(
        id: json['id'] as int,
        event: json['event'] as String?,
        description: json['description'] as String?,
        causedBy: json['caused_by'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}
