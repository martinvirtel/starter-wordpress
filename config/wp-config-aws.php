<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

if ( isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') $_SERVER['HTTPS']='on';

require dirname(__FILE__).'/../config/settings.php';

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

/*
define('AUTH_KEY',         'wK~J+H-0=PkVRq=E-oNV (+yg7;q3[_@d2*Fh!a[#X7o=6&R-~hO6H65Y35:)w<}');
define('SECURE_AUTH_KEY',  '546$>TSrAi![o._-G?= 0M*?3pUniq]=Tu]SCYm:}QT=P!$^Dv*P)rn38ANy-css');
define('LOGGED_IN_KEY',    'H--z|G _#5T{qa)-.#pOh@7))mE@^YFKB^v|W3Cf[-d_73uFBxgST.+8&!+wFZKv');
define('NONCE_KEY',        '34|DK;Lz)0btM^N7v+in-|=f-+KY}64s?FtLNH#Fl8]pR;p|6}SE%$&*)yLH4+,o');
define('AUTH_SALT',        'og3AqB6}F!|:M0h!8&jDVUey@8GW8egb.{D0aH|Zb:LUX^-%~U/hql1Fr!e%k$d|');
define('SECURE_AUTH_SALT', '-G,G^zeiho]V2$/a^)[h;f)6)8Od0!iBllj>WTfnT[W0.}6|Q%!C,<#BKSW|>|{c');
define('LOGGED_IN_SALT',   '}./]giyQS?(a oKIb+F,-uHu|O_.yO4xJ`2}k(z~boY_DO`In!>?K^({+OZ4=@UE');
define('NONCE_SALT',       '#]E fW+rmLKB1p829w~%,.:TjB5,jB0$LK6D>,qn76<.Rny?F3cc^R/zD-M%mt>x');
 */
/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
/* define('WP_DEBUG', false); */
/* define('PH_ENV', "PRODUCTION"); */
define('DISABLE_WP_CRON', true);

//define('COOKIE_DOMAIN', 'versicherungsmonitor.de');

/**
 * Lexware Export (de-)aktivieren.
 */
//define('ENABLE_EXPORT', (bool) getenv('ENABLE_EXPORT'));
define('ENABLE_EXPORT', true);

/**
 * E-Mail Adresse für den Empfang von Fehlermeldungen beim Lexware Export.
 */
//define('ERROR_MAIL', getenv('ERROR_MAIL')); // abo@versicherungsmonitor.de
define('ERROR_MAIL', 'abo@versicherungsmonitor.de, webmaster-vmo@palasthotel.de');
define('LEXWARE_EXPORT_MAIL','abo@versicherungsmonitor.de');

// webdav
define('WEBDAV_URL', 'https://remote.pressebuero-fromme.de:5006');
define('WEBDAV_FOLDER', 'VM2LEX');
define('WEBDAV_USER', 'vm2lex');
define('WEBDAV_PASSWORD', '1Dy15A#3');

define('OCTAVIUS_ROCKS_API_KEY', '580f4ace-faa4-4796-9524-7b91d5ac3388');
define('OCTAVIUS_ROCKS_CLIENT_SECRET', '367f3508-8e2b-4d8c-9a4a-b87fd13c49d1');
define('OCTAVIUS_ROCKS_TRACK_CLICKS', true);
define('OCTAVIUS_ROCKS_TRACK_RENDERED', false);
define('OCTAVIUS_ROCKS_TRACK_PIXEL', false);

// Sentry.Palasthotel.de Settings
/* require_once dirname(__FILE__)."/wp-config-sentry.php"; */
/* define('WP_SENTRY_ENV', 'flying_production'); */

require_once dirname(__FILE__)."/wp-config-env-info.php";

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
