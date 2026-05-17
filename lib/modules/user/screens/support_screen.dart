import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _topic = 'Lỗi tài khoản';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF7A2E2E),
          content: Text('Vui lòng nhập nội dung phản hồi ít nhất 10 ký tự'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2F6B3B),
        content: Text('Đã ghi nhận phản hồi: $_topic'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Hỗ trợ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0A07),
        foregroundColor: const Color(0xFFF6E7BE),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF17110C),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF735624)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: Color(0xFFE0B85C)),
                    SizedBox(width: 10),
                    Text(
                      'Trung tâm hỗ trợ',
                      style: TextStyle(
                        color: Color(0xFFF6E7BE),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Bạn có thể gửi phản hồi về lỗi đăng nhập, mất vật phẩm, lỗi đọc truyện hoặc góp ý tính năng. Phần này đang xử lý nội bộ trong app; nếu muốn lưu ticket thật vào database thì cần bổ sung API support ở backend.',
                  style: TextStyle(color: Color(0xFFCCB991), height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FaqCard(
            question: 'Không thấy vật phẩm sau khi mua?',
            answer: 'Hãy kéo xuống để refresh Túi đồ. Nếu backend đã ghi nhận giao dịch thì vật phẩm sẽ xuất hiện trong danh sách sở hữu.',
          ),
          const SizedBox(height: 10),
          _FaqCard(
            question: 'Lịch sử đọc không cập nhật?',
            answer: 'Lịch sử phụ thuộc vào bảng reading_history trong backend. Nếu đọc chapter nhưng chưa insert/update lịch sử thì cần kiểm tra API reader.',
          ),
          const SizedBox(height: 10),
          _FaqCard(
            question: 'Theo dõi truyện dùng như thế nào?',
            answer: 'Vào chi tiết truyện và bấm Theo dõi. Danh sách này sẽ lấy từ API /profile/me/follows.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF17110C),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF735624)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gửi phản hồi nhanh',
                  style: TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _topic,
                  dropdownColor: const Color(0xFF17110C),
                  decoration: _inputDecoration('Chủ đề'),
                  style: const TextStyle(color: Color(0xFFF6E7BE)),
                  items: const [
                    DropdownMenuItem(value: 'Lỗi tài khoản', child: Text('Lỗi tài khoản')),
                    DropdownMenuItem(value: 'Lỗi đọc truyện', child: Text('Lỗi đọc truyện')),
                    DropdownMenuItem(value: 'Lỗi vật phẩm / thanh toán', child: Text('Lỗi vật phẩm / thanh toán')),
                    DropdownMenuItem(value: 'Góp ý tính năng', child: Text('Góp ý tính năng')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _topic = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 6,
                  style: const TextStyle(color: Color(0xFFF6E7BE)),
                  decoration: _inputDecoration('Nội dung phản hồi'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Gửi phản hồi'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC7962F),
                      foregroundColor: const Color(0xFF24170B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB89E70)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5E451D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC7962F), width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFF23180F),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(color: Color(0xFFCCB991), height: 1.4),
          ),
        ],
      ),
    );
  }
}
