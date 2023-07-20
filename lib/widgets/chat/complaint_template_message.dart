import 'package:hustle_stay/models/complaint/complaint.dart';
import 'package:hustle_stay/models/requests/mess/menu_change_request.dart';
import 'package:hustle_stay/models/requests/vehicle/vehicle_request.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools.dart';

String complaintTemplateMessage(ComplaintData complaint) {
  return "Hi ${complaint.to}, \n\nI hope you're doing well. I wanted to bring to your attention a concerning issue regarding **${complaint.title.trim()}**. ${complaint.description != null ? "\n\n${complaint.description!.trim().replaceAll('\n', '\n\n')}" : ""}\n\nI kindly request your immediate attention to this matter. Clear communication and updates throughout the process would be greatly appreciated. \n\nThank you for your understanding, and I look forward to a satisfactory resolution. \n\nBest Regards, \n\nCodeSoc${complaint.imgUrl != null ? "\n\n---\n\n![Image](${complaint.imgUrl})" : ''}";
}

String vanRequestTemplateMessage(VehicleRequest request, String title) {
  final title = request.reason.split(':')[0];
  return "Dear ${request.approvers},\n\nI hope this message finds you well. May I request permission to use the college van for $title on ${ddmmyyyy(request.dateTime!)} at ${timeFrom(request.dateTime!)}?${request.reason.length > title.length + 2 ? " The purpose is ${request.reason.substring(title.length + 2)}." : ""}\n\nThank you for your consideration.\n\nBest regards,\n\n${currentUser.name ?? currentUser.email}";
}

String messMenuChangeMessage(MenuChangeRequest request) {
  return 'Dear ${request.approvers},\n\nKindly consider this mess menu change request: ${request.reason}. \n\nThank you for your attention to this matter.\n\nSincerely,\n\n${request.requestingUserEmail}';
}
