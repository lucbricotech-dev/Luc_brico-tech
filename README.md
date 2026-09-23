# Luc Brico-Tech — version prête à mettre en ligne

## Architecture
- Frontend : `index.html` (interface web responsive)
- Base de données : PostgreSQL via Supabase
- Authentification : Supabase Auth
- Hébergement recommandé : Vercel
- Sécurité : Row Level Security (RLS)

## Mise en ligne
1. Créer un projet Supabase.
2. Ouvrir SQL Editor et exécuter `database/schema.sql`.
3. Configurer l'authentification Email/Password dans Supabase.
4. Créer un dépôt GitHub et y envoyer `index.html`.
5. Importer le dépôt dans Vercel.
6. Ajouter les variables d'environnement Supabase.
7. Déployer.
8. Ajouter ensuite le nom de domaine de Luc Brico-Tech.

## Important
Le fichier HTML fourni est la maquette fonctionnelle professionnelle. La connexion Supabase doit être branchée dans le JavaScript avant la mise en production pour que les ventes, achats, activités et projets soient réellement stockés en ligne.

Ne jamais exposer une clé `service_role` dans le navigateur. Utiliser uniquement la clé publiable côté client et protéger les tables avec RLS.
