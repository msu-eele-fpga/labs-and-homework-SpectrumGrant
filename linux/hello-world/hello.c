#include <linux/module.h>
#include <linux/printk.h>

static int __init init_function(void);

static void __exit cleanup_function(void);

module_init(init_function);
module_exit(cleanup_function);

static int __init init_function(void) {
	pr_info("Hello World!\n");
	return 0;
}

static void __exit cleanup_function(void) {
	pr_info("Goodbye, cruel world\n");
}

MODULE_LICENSE();
MODULE_AUTHOR("Grant Kirkland");
MODULE_DESCRIPTION("A simple hello world kernel module");