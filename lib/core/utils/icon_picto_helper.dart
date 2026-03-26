import 'package:flutter/material.dart';

class Category {
  final String name;
  final String description;
  final IconData icon;

  Category({
    required this.name,
    required this.description,
    required this.icon,
  });
}

List<Category> listPicto = [
  Category(name: 'Hôtel de ville', description: 'Accès aux infos de la mairie', icon: Icons.location_city),
  Category(name: 'Démarches administratives', description: "Papiers, cartes d'identité, etc.", icon: Icons.assignment),
  Category(name: 'Prise de rendez-vous', description: 'Pour les démarches en ligne', icon: Icons.calendar_today),
  Category(name: 'Conseil municipal', description: 'Infos sur les réunions municipales', icon: Icons.people),
  Category(name: 'Élus / Maire', description: 'Liste des élus, contacts', icon: Icons.person),
  Category(name: 'Documents officiels', description: 'Téléchargement PDF, certificats', icon: Icons.file_copy),

  // Santé / Hôpital
  Category(name: 'Urgences', description: 'Accès rapide aux urgences', icon: Icons.local_hospital),
  Category(name: 'Médecins', description: 'Liste des praticiens', icon: Icons.local_hospital),
  Category(name: 'Pharmacie', description: 'Trouver une pharmacie proche', icon: Icons.local_pharmacy),
  Category(name: 'RDV médical', description: 'Prendre un rdv chez un médecin', icon: Icons.calendar_today),
  Category(name: 'Vaccination', description: 'Centres et campagnes vaccinales', icon: Icons.sick),
  Category(name: 'Don de sang', description: 'Infos et lieux de collecte', icon: Icons.bloodtype),

  // Transports / Mobilité
  Category(name: 'Bus', description: 'Horaires et lignes de bus', icon: Icons.directions_bus),
  Category(name: 'Tram', description: 'Ligne et horaires de tramway', icon: Icons.directions_railway),
  Category(name: 'Parking', description: 'Parkings disponibles', icon: Icons.local_parking),
  Category(name: 'Vélo / Vélopartage', description: 'Station vélo ou location', icon: Icons.directions_bike),
  Category(name: 'Bornes électriques', description: 'Recharge de véhicules', icon: Icons.electric_car),
  Category(name: 'Info trafic', description: 'État du trafic routier', icon: Icons.traffic),

  // Éducation / Petite enfance
  Category(name: 'Écoles', description: 'Liste des écoles publiques/privées', icon: Icons.school),
  Category(name: 'Crèches', description: 'Infos et inscriptions', icon: Icons.child_care),
  Category(name: 'Inscriptions scolaires', description: "Portail d'inscription", icon: Icons.library_books),
  Category(name: 'Cantine', description: 'Menus, paiement, inscription', icon: Icons.fastfood),
  Category(name: 'Calendrier scolaire', description: 'Jours fériés, vacances', icon: Icons.calendar_today),

  // Services de proximité
  Category(name: 'Poste', description: 'Bureau de poste', icon: Icons.mail),
  Category(name: 'Commissariat / Sécurité', description: 'Police, signalements', icon: Icons.security),
  Category(name: 'Pompiers', description: 'Appel et infos pompiers', icon: Icons.fire_truck),
  Category(name: 'Associations locales', description: 'Liste des assos / activités', icon: Icons.handshake),
  Category(name: 'Centre social', description: 'Infos sociales, aides', icon: Icons.home),
  Category(name: 'Service citoyen / Aide', description: 'Contacter la mairie, aide aux démarches', icon: Icons.phone),

  // Événements / Culture
  Category(name: 'Agenda', description: 'Tous les événements', icon: Icons.event),
  Category(name: 'Concert / Spectacle', description: 'Programmation culturelle', icon: Icons.music_note),
  Category(name: 'Cinéma', description: 'Films en salle', icon: Icons.movie),
  Category(name: 'Expositions', description: 'Musées, galeries', icon: Icons.photo_album),
  Category(name: 'Marchés / Fêtes', description: 'Marchés locaux, foires', icon: Icons.local_offer),

  // Sport / Loisirs
  Category(name: 'Piscine', description: 'Horaires et lieux', icon: Icons.pool),
  Category(name: 'Stade / Gymnase', description: 'Sports collectifs, entraînements', icon: Icons.sports),
  Category(name: 'Club de sport', description: 'Infos et inscriptions', icon: Icons.sports_soccer),
  Category(name: 'Aire de jeux', description: 'Enfants / parcs', icon: Icons.child_friendly),
  Category(name: 'Randonnée / Parcours', description: 'Sentiers, balades', icon: Icons.directions_walk),

  // Cartographie / Lieux
  Category(name: 'Carte de la ville', description: 'Plan interactif', icon: Icons.map),
  Category(name: 'Quartiers', description: 'Sélection des zones', icon: Icons.location_on),
  Category(name: 'Monuments', description: "Points d'intérêt historiques", icon: Icons.history),
  Category(name: 'Bâtiments publics', description: 'Accès aux services', icon: Icons.business),
  Category(name: 'Lieux touristiques', description: 'À visiter', icon: Icons.place),

  // Fonctions techniques (génériques)
  Category(name: 'Accueil', description: 'Écran principal', icon: Icons.home),
  Category(name: 'Rechercher', description: 'Recherche de contenu', icon: Icons.search),
  Category(name: 'Notifications', description: 'Alertes et messages', icon: Icons.notifications),
  Category(name: 'Mon compte', description: 'Espace personnel', icon: Icons.account_circle),
  Category(name: 'Paramètres', description: 'Préférences, langue, etc.', icon: Icons.settings),

  // Environnement / Propreté
  Category(name: 'Déchets / Poubelles', description: 'Collectes, types de déchets', icon: Icons.delete),
  Category(name: 'Recyclage', description: 'Tri sélectif, bornes', icon: Icons.recycling),
  Category(name: 'Déchetterie', description: 'Localisation et horaires', icon: Icons.delete_forever),
  Category(name: 'Pollution / Qualité de l’air', description: 'Infos en temps réel', icon: Icons.air),
  Category(name: 'Espaces verts / Parcs', description: 'Localisation et horaires', icon: Icons.park),
];
