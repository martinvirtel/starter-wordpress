<?php
/**
 * Grundeinstellungen für WordPress
 *
 * Zu diesen Einstellungen gehören:
 *
 * * MySQL-Zugangsdaten,
 * * Tabellenpräfix,
 * * Sicherheitsschlüssel
 * * und ABSPATH.
 *
 * Mehr Informationen zur wp-config.php gibt es auf der
 * {@link https://codex.wordpress.org/Editing_wp-config.php wp-config.php editieren}
 * Seite im Codex. Die Zugangsdaten für die MySQL-Datenbank
 * bekommst du von deinem Webhoster.
 *
 * Diese Datei wird zur Erstellung der wp-config.php verwendet.
 * Du musst aber dafür nicht das Installationsskript verwenden.
 * Stattdessen kannst du auch diese Datei als wp-config.php mit
 * deinen Zugangsdaten für die Datenbank abspeichern.
 *
 * @package WordPress
 */

// ** MySQL-Einstellungen ** //
/**   Diese Zugangsdaten bekommst du von deinem Webhoster. **/

/**
 * Ersetze datenbankname_hier_einfuegen
 * mit dem Namen der Datenbank, die du verwenden möchtest.
 */

define( 'DB_NAME', getenv('DB_NAME'));

/**
 * Ersetze benutzername_hier_einfuegen
 * mit deinem MySQL-Datenbank-Benutzernamen.
define( 'DB_USER', 'benutzername_hier_einfuegen' );
 */

define( 'DB_USER', getenv('DB_USER'));
/**
 * Ersetze passwort_hier_einfuegen mit deinem MySQL-Passwort.
 */
define( 'DB_PASSWORD', getenv('DB_PASSWORD'));

/**
 * Ersetze localhost mit der MySQL-Serveradresse.
define( 'DB_HOST', 'localhost' );
 */
define( 'DB_HOST', getenv('DB_HOST'));

/**
 * Der Datenbankzeichensatz, der beim Erstellen der
 * Datenbanktabellen verwendet werden soll
 */
define( 'DB_CHARSET', 'utf8' );

/**
 * Der Collate-Type sollte nicht geändert werden.
 */
define('DB_COLLATE', '');

/**#@+
 * Sicherheitsschlüssel
 *
 * Ändere jeden untenstehenden Platzhaltertext in eine beliebige,
 * möglichst einmalig genutzte Zeichenkette.
 * Auf der Seite {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * kannst du dir alle Schlüssel generieren lassen.
 * Du kannst die Schlüssel jederzeit wieder ändern, alle angemeldeten
 * Benutzer müssen sich danach erneut anmelden.
 *
 * @since 2.6.0
 */

define('AUTH_KEY',         '4Hzl#v~{-~,+3MkSC7+tBXr1BEg[LL]XJJf6]stq^dI@S:RqAgiS+,K;kqJX!K]R');
define('SECURE_AUTH_KEY',  'V$czxSv^Z=S|;ldiFlQVlD;M}A$FLgc|L+?XQS thrie~U.yOTUmDSOg%P]|&tly');
define('LOGGED_IN_KEY',    'GJp1{0f6m;,h3EAs&kDLN$JXYL,NTyL -28-FJiQdoEH_+a~wXms]-uLxvl4DvW9');
define('NONCE_KEY',        '~%`h>Q,}[jtWNLYV0--9K>5e4+d;~HQV0Uel.Tx$,[7m|F~q)3U6b5zAt_{]TCV0');
define('AUTH_SALT',        '&P:%!~F u8820U7WojNh[RVrS]=z551wpn)8%W0],7R@sHRqB?M?Jt&; XY6HQu&');
define('SECURE_AUTH_SALT', '-`07F1M!AG9uKedu:>Z`lT?>J5Ndie2P5Hfq^m>:wYA-nI|j9kO%HZ,Y5Lk#kDN+');
define('LOGGED_IN_SALT',   '.;unIF[gE2p<UsX_QO,0YgPz4|~kpDA(WP3v#>}ZPu4e2tY_VzPv{s9L75/B/m/k');
define('NONCE_SALT',       'mFbpAHu;$i{WLT*C=Z~(H+(?t}E1d5|htYP%;aF:DptL?rz1hv|@fbU92  B5i6w');

/**#@-*/

/**
 * WordPress Datenbanktabellen-Präfix
 *
 * Wenn du verschiedene Präfixe benutzt, kannst du innerhalb einer Datenbank
 * verschiedene WordPress-Installationen betreiben.
 * Bitte verwende nur Zahlen, Buchstaben und Unterstriche!
 */
$table_prefix = 'wp_';

/**
 * Für Entwickler: Der WordPress-Debug-Modus.
 *
 * Setze den Wert auf „true“, um bei der Entwicklung Warnungen und Fehler-Meldungen angezeigt zu bekommen.
 * Plugin- und Theme-Entwicklern wird nachdrücklich empfohlen, WP_DEBUG
 * in ihrer Entwicklungsumgebung zu verwenden.
 *
 * Besuche den Codex, um mehr Informationen über andere Konstanten zu finden,
 * die zum Debuggen genutzt werden können.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', false );

/* Das war’s, Schluss mit dem Bearbeiten! Viel Spaß. */
/* That's all, stop editing! Happy publishing. */

/** Der absolute Pfad zum WordPress-Verzeichnis. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Definiert WordPress-Variablen und fügt Dateien ein.  */
require_once( ABSPATH . 'wp-settings.php' );
