import 'package:flutter/material.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({super.key});

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Первая страница',
    'Вторая страница',
    'Третья страница',
  ];

  final List<IconData> _icons = [
    Icons.task_alt,
    Icons.calendar_month,
    Icons.person,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PageView'),
        backgroundColor: const Color(0xFFE8D7FF),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _titles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _icons[index],
                        size: 100,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _titles[index],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Страница ${index + 1} из ${_titles.length}'),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Назад'),
                ),
                Text('${_currentPage + 1} / ${_titles.length}'),
                ElevatedButton(
                  onPressed: _currentPage < _titles.length - 1
                      ? () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  child: const Text('Далее'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}