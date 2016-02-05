```
#include <glib.h>
```

Compile (编译库)
--------------

```
$ gcc -o test test.c `pkg-config --cflags --libs glib-2.0`
```

GHashTable (哈希表)
-----------------

```
GHashTable *g_hash_table_new(g_str_hash, g_str_equal)

gboolean    g_hash_table_insert(GHashTable *hash, gpointer key, gpointer value)

gpointer    g_hash_table_lookup(GHashTable *hash, gpointer key)

gboolean    g_hash_table_remove(GHashTable *hash, gpointer key)

guint       g_hash_table_size(GHashTable    hash)

void        g_hash_table_foreach(GHashTable *hash, GHFunc *ghfunc)

void        g_hash_table_destroy(GHashTable *hash)

void        (*GHFunc)(gpointer key, gpointer value, gpointer user_data)

```


Example (示例)
-------------

```
#include <stdio.h>
#include <glib.h>

int main(int argc, char** argv) {
	GHashTable *hash = g_hash_table_new(g_str_hash, g_str_equal);
	g_hash_table_insert(hash, "A", "123");
	g_hash_table_insert(hash, "B", "126");
	g_printf("There are %d keys in the hash.\n", g_hash_table_size(hash));
	g_printf("The A of hash is %s.\n",           g_hash_table_lookup(hash, "A"));
	g_printf("The B of hash is %s.\n",           g_hash_table_lookup(hash, "B"));
	g_hash_table_remove(hash, "A");
	g_printf("The A of hash is %s.\n",           g_hash_table_lookup(hash, "A"));
	g_printf("The B of hash is %s.\n",           g_hash_table_lookup(hash, "B"));
	g_hash_table_destroy(hash);
	return 0;
}
```