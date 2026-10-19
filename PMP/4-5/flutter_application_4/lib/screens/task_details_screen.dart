import 'package:flutter/material.dart';
import '../widgets/attachment_tile_widget.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height:12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              const Text(
                'Task details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smartphone, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Weardrop app', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Mobile Version', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildDateCard('Start Date', '22 October 2022')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateCard('Due Date', '22 October 2022')),
                ],
              ),
              const SizedBox(height: 16),

              _buildDetailRow(
                'Status',
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9FA8DA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('In Progress', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              _buildDetailRow(
                'Assigned for',
                const Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: Colors.blue),
                    SizedBox(width: 4),
                    CircleAvatar(radius: 12, backgroundColor: Colors.brown),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildDetailRow(
                'Priority',
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2FFD2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Low', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              _buildDetailRow(
                'Tags',
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0B2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('On Track', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3D2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('At Risk', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              AttachmentTileWidget(
                fileName: 'Developer Document.pdf',
                info: '2.5 MB PDF',
                icon: Icons.picture_as_pdf,
                iconBgColor: Colors.red.shade100,
                iconColor: Colors.red,
              ),
              const SizedBox(height: 8),
              AttachmentTileWidget(
                fileName: 'Mobile application brief.doc',
                info: '2.5 MB Document',
                icon: Icons.description,
                iconBgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        content,
      ],
    );
  }
}