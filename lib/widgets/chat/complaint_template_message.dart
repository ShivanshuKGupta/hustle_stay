import 'package:hustle_stay/models/complaint.dart';

String complaintTemplateMessage(ComplaintData complaint) {
  return "Hi ${complaint.to}, \n\nI hope you're doing well. I wanted to bring to your attention a concerning issue regarding **${complaint.title.trim()}**. ${complaint.description != null ? "\n\n${complaint.description!.trim().replaceAll('\n', '\n\n')}" : ""}\n\nI kindly request your immediate attention to this matter. Clear communication and updates throughout the process would be greatly appreciated. \n\nThank you for your understanding, and I look forward to a satisfactory resolution. \n\nBest Regards, \n\nCodeSoc${complaint.imgUrl != null ? "\n\n---\n\n![Image](${complaint.imgUrl})" : ''}";
}
