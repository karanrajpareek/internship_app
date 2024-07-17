import 'package:flutter/material.dart';
import 'api_service.dart';
import 'internship_model.dart';
import 'filter_model.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internship App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class InternshipListScreen extends StatefulWidget {
  const InternshipListScreen({super.key});

  @override
  _InternshipListScreenState createState() => _InternshipListScreenState();
}

class _InternshipListScreenState extends State<InternshipListScreen> {
  late Future<List<Internship>> _futureInternships;
  Filter _currentFilter = Filter(profile: '', city: '', duration: '');

  @override
  void initState() {
    super.initState();
    _futureInternships = ApiService.fetchInternships();
  }

  void _applyFilter(Filter filter) {
    setState(() {
      _currentFilter = filter;
      _futureInternships = ApiService.fetchInternships().then((internships) {
        return internships.where((internship) {
          final matchesProfile = _currentFilter.profile.isEmpty ||
              internship.profileName.toLowerCase().contains(_currentFilter.profile.toLowerCase());
          final matchesCity = _currentFilter.city.isEmpty ||
              internship.locationNames.any((city) => city.toLowerCase().contains(_currentFilter.city.toLowerCase()));
          final matchesDuration = _currentFilter.duration.isEmpty ||
              internship.duration.toLowerCase().contains(_currentFilter.duration.toLowerCase());
          return matchesProfile && matchesCity && matchesDuration;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internships'),
      ),
      drawer: Drawer(
        child: FilterPanel(
          currentFilter: _currentFilter,
          onApply: _applyFilter,
        ),
      ),
      body: FutureBuilder<List<Internship>>(
        future: _futureInternships,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No internships found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Internship internship = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(
                        'https://internshala.com/static/images/branding/logo/google_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(internship.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Company: ${internship.companyName}'),
                        Text('Location: ${internship.locationNames.join(", ")}'),
                        Text('Duration: ${internship.duration}'),
                        Text('Stipend: ${internship.stipend}'),
                        Text('Apply by: ${internship.applicationDeadline}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FilterPanel extends StatefulWidget {
  final Filter currentFilter;
  final Function(Filter) onApply;

  const FilterPanel({super.key, required this.currentFilter, required this.onApply});

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final _formKey = GlobalKey<FormState>();
  late String _profile;
  late String _city;
  late String _duration;

  @override
  void initState() {
    super.initState();
    _profile = widget.currentFilter.profile;
    _city = widget.currentFilter.city;
    _duration = widget.currentFilter.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: _profile,
              decoration: const InputDecoration(labelText: 'Profile'),
              onChanged: (value) => _profile = value,
            ),
            TextFormField(
              initialValue: _city,
              decoration: const InputDecoration(labelText: 'City'),
              onChanged: (value) => _city = value,
            ),
            TextFormField(
              initialValue: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
              onChanged: (value) => _duration = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onApply(Filter(
                  profile: _profile,
                  city: _city,
                  duration: _duration,
                ));
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
