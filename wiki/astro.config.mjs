// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
	site: 'https://wiki-si-ngacir.cyphera.my.id',
	integrations: [
		starlight({
			title: 'Wiki Si Ngacir',
			description: 'Wiki resmi Si Ngacir, game arcade tentang Masbro si capybara kurir.',
			logo: { src: './public/img/portraits/masbro_mantap.svg', alt: 'Masbro' },
			favicon: '/favicon.svg',
			defaultLocale: 'root',
			locales: {
				root: { label: 'Bahasa Indonesia', lang: 'id' },
				en: { label: 'English', lang: 'en' },
			},
			social: [
				{ icon: 'external', label: 'Main di itch.io', href: 'https://cyphera-game.itch.io/si-ngacir' },
			],
			customCss: ['./src/styles/custom.css'],
			lastUpdated: true,
			sidebar: [
				{
					label: 'Tentang Game',
					translations: { en: 'About the Game' },
					items: [
						{ slug: 'tentang/cerita', label: 'Cerita', translations: { en: 'Story' } },
						{ slug: 'tentang/tokoh', label: 'Tokoh', translations: { en: 'Characters' } },
					],
				},
				{
					label: 'Cara Bermain',
					translations: { en: 'How to Play' },
					items: [
						{ slug: 'bermain/mulai', label: 'Mulai Bermain', translations: { en: 'Getting Started' } },
						{ slug: 'bermain/aturan', label: 'Aturan & Upah', translations: { en: 'Rules & Pay' } },
						{ slug: 'bermain/hari', label: 'Lima Hari', translations: { en: 'The Five Days' } },
						{ slug: 'bermain/rintangan', label: 'Rintangan & Item', translations: { en: 'Hazards & Items' } },
						{ slug: 'bermain/tips', label: 'Tips & Masalah Umum', translations: { en: 'Tips & Troubleshooting' } },
					],
				},
				{
					label: 'Fitur',
					translations: { en: 'Features' },
					items: [
						{ slug: 'fitur/toko', label: 'Toko Masbro', translations: { en: "Masbro's Shop" } },
						{ slug: 'fitur/album', label: 'Cutscene & Album', translations: { en: 'Cutscenes & Album' } },
						{ slug: 'fitur/pengaturan', label: 'Pengaturan & Aksesibilitas', translations: { en: 'Settings & Accessibility' } },
					],
				},
				{
					label: 'Pengembangan',
					translations: { en: 'Development' },
					items: [
						{ slug: 'pengembangan/desain', label: 'Desain Game', translations: { en: 'Game Design' } },
						{ slug: 'pengembangan/teknologi', label: 'Teknologi', translations: { en: 'Technology' } },
						{ slug: 'pengembangan/tampilan-3d', label: 'Tampilan 3D', translations: { en: '3D View' } },
						{ slug: 'pengembangan/kontribusi', label: 'Panduan Kontribusi', translations: { en: 'Contributing' } },
						{ slug: 'pengembangan/riwayat-versi', label: 'Riwayat Versi', translations: { en: 'Changelog' } },
						{ slug: 'pengembangan/roadmap', label: 'Rencana', translations: { en: 'Roadmap' } },
					],
				},
				{ slug: 'tim', label: 'Tim Pengembang', translations: { en: 'Team' } },
			],
		}),
	],
});
