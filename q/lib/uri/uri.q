/#######
/# URI #
/#######

.uri.chr:.Q.an,.Q.sc," ";
/ URI-safe - String: characters that do not need to be escaped in URIs
.uri.sc:.h.sc;
/ URI escape - URI-unsafe characters replaced with safe equivalents
.uri.enc:.h.hu;
/ URI unescape - %xx hex sequences replaced with character equivalents
.uri.dec:.h.uh;
/ URI map - returns a mapping from characters to %xx escape sequences except for the chars in x, which get mapped to themselves
/ @example - (.uri.map"custom safe characters @_~")"unsafe characters will be replaced with safe equivalents"
.uri.map:.h.hug;
