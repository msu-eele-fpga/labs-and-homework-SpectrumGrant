#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>

static const struct of_device_id led_patterns_of_match[];
static int led_patterns_probe(struct platform_device *pdev);
static int led_patterns_remove(struct platform_device *pdev);

/*struct platform_driver {
	int (*probe)(struct platform_device *);
	int (*remove)(struct platform_device *);
	struct device_driver driver;
}; */


/**
 * struct led_patterns_driver - Platform driver struct for the led_patterns driver
 * @probe: Function that's called when a device is found
 * @remove: Function that's called when a device is removed
 * @driver.owner: Which module owns this driver
 * @driver.name: Name of the led_patterns driver
 * @driver.of_match_table: Device tree match table
 */
static struct platform_driver led_patterns_driver = {
	.probe = led_patterns_probe,
	.remove = led_patterns_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name = "led_patterns",
		.of_match_table = led_patterns_of_match,
	},
};

module_platform_driver(led_patterns_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Grant Kirkland");
MODULE_DESCRIPTION("led_patterns driver");

/**
 * led_patterns_probe() - Initialize device when a match is found
 * @pdev: Platform device structure associated with our led patterns device;
 * 	pdev is automatically created by the driver core based upon our 
 * 	led patterns device tree node.
 * 
 * When a device that is compatible with this led patterns driver is found, the
 * driver's probe function is called. This probe function gets called by the
 * kernel when an led_patterns device is found in the device tree. 
 */
static int led_patterns_probe(struct platform_device *pdev) {
	pr_info("led_patterns_probe\n");

	return 0;
}

/**
 * led_patterns_remove() - Remove a led patterns device.
 * @pdev: Platform device structure associated with our led patterns device.
 * 
 * This function is called when an led patterns device is removed or
 * the driver is removed
 */
static int led_patterns_remove(struct platform_device *pdev) {
	pr_info("led_patterns_remove\n");

	return 0;
}

/**
 * Define the compatible property used for matching devices to this driver,
 * then add our device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same 
 * compatible string as defined here.
 */
static const struct of_device_id led_patterns_of_match[] = {
	{ .compatible = "Kirkland,led_patterns", },
	{ }	
};
MODULE_DEVICE_TABLE(of, led_patterns_of_match);
