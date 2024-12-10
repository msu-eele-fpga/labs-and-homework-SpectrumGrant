#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>

#define HPS_LED_CONTROL_OFFSET 0
#define BASE_PERIOD_OFFSET 4
#define LED_REG_OFFSET 8

static const struct of_device_id led_patterns_of_match[];
static int led_patterns_probe(struct platform_device *pdev);
static int led_patterns_remove(struct platform_device *pdev);

/*struct platform_driver {
	int (*probe)(struct platform_device *);
	int (*remove)(struct platform_device *);
	struct device_driver driver;
}; */

/**
 * struct led_patterns_dev - Private led patterns device struct.
 * @base_addr: Pointer to the component's base address
 * @hps_led_control: Address of the hps_led_control register
 * @base_period: Address of the base_period register
 * @led_reg: Address of the led_reg register
 *
 * An led_patterns_dev struct gets created for each led patterns component.
 */
struct led_patterns_dev {
	void __iomem *base_addr;
	void __iomem *hps_led_control;
	void __iomem *base_period;
	void __iomem *led_reg;
};

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
	struct led_patterns_dev *priv;

	/*
	 * Allocate kernel memory for the led patterns device and set it to 0.
	 * GFP_KERNEL specifies that we are allocating normal kernel RAM;
	 * see the kmalloc documentation for more info. The allocated memory
	 * is automatically freed when the device is removed. 
	 */

	priv = devm_kzalloc(&pdev->dev, sizeof(struct led_patterns_dev), GFP_KERNEL);

	if (!priv) {
		pr_err("Failed to allocate memory\n");
		return -ENOMEM;
	}

	/*
	 * Request and remap the device's memory region. Requesting the region
	 * makes sure nobody else can use that memory. The memory is remapped 
	 * into the kernel's virtual address space because we don't have access
	 * to physical memory locations. 
	 */
	priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
	
	if (IS_ERR(priv->base_addr)) {
		pr_err("Failed to request/remap platform device resource\n");
		return PTR_ERR(priv->base_addr);
	}

	// Set the memory addresses for each register.
	priv->hps_led_control = priv->base_addr + HPS_LED_CONTROL_OFFSET;
	priv->base_period = priv->base_addr + BASE_PERIOD_OFFSET;
	priv->led_reg = priv->base_addr + LED_REG_OFFSET;

	// Enable software-control mode and turn all the LEDs on, just for fun.
	iowrite32(1, priv->hps_led_control);
	iowrite32(0xff, priv->led_reg);

	/* Attatch the led pattern's private data to the platform device's struct.
	 * This is so we can access our state container in the other functions.
	 */
	platform_set_drvdata(pdev, priv);

	pr_info("led_patterns_probe successful\n");

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
	// get the led patterns's private data from the platform device.
	struct led_patterns_dev *priv = platform_get_drvdata(pdev);

	// Disable software-control mode, just for kicks.
	iowrite32(0, priv->hps_led_control);

	pr_info("led_patterns_remove successful\n");

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
