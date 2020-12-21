### 1.0.1

Most of the game is playable.

Chat and combat are not handled at all; either will likely raise an
exception.

This release saves system information in a local sqlite database.  This
information will be used to support a "jump to (x,y)" feature.  The db
is saved to ~/.textflight/client/production.db.
