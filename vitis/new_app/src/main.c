#include "xgpiops.h"
#include "xparameters.h"

#include "fifo_platform.h"
#include "ad9361_platform.h"

/* GPIO defines */
#define GPIO_RESET_PIN 54+0
#define GPIO_DEVICE_ID XPAR_PS7_GPIO_0_DEVICE_ID
#define SPI_DEVICE_ID XPAR_PS7_SPI_0_DEVICE_ID

#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID

struct ad9361_rf_phy *ad9361_phy;

int main(void){

	int32_t res;
	u32 mode;
	XGpioPs my_gpio;
	XGpioPs_Config *cfg_ptr;

	int Status;

	/* -------------- AD9361 init -------------- */
	default_init_param.gpio_resetb = GPIO_RESET_PIN;
	gpio_init(GPIO_DEVICE_ID);
	gpio_direction(default_init_param.gpio_resetb, 1);

	spi_init(SPI_DEVICE_ID, 1, 0);
	res = ad9361_init(&ad9361_phy, &default_init_param);
	res = ad9361_set_rx_fir_config(ad9361_phy, rx_fir_config);
	res = ad9361_set_tx_fir_config(ad9361_phy, tx_fir_config);
	uint32_t sr = 2084000;		//10240000; //15360000;
	ad9361_get_tx_sampling_freq (ad9361_phy, &sr);
	ad9361_get_rx_sampling_freq (ad9361_phy, &sr);

	// xil_printf("Hello\n");
	
	cfg_ptr = XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&my_gpio, cfg_ptr, cfg_ptr->BaseAddr);
	XGpioPs_SetDirectionPin(&my_gpio, 55, 1);
	XGpioPs_SetOutputEnablePin(&my_gpio, 55, 1);
	XGpioPs_SetDirectionPin(&my_gpio, 56, 1);
	XGpioPs_SetOutputEnablePin(&my_gpio, 56, 1);
	XGpioPs_WritePin(&my_gpio, 55,1);
	XGpioPs_WritePin(&my_gpio, 56,1);

	/* --------------------------------------- */

	xil_printf("--- Welcome to simple_sdr API ---\n\r");

	while(1)
	{
		/* Check ad9361 state machine status for debug */
		ad9361_get_en_state_machine_mode(ad9361_phy, &mode);

		Status = FifoPolling(&FifoInstance, FIFO_DEV_ID);
		if (Status != XST_SUCCESS)
		{
			xil_printf(" Test Failed. Output data doesn't match input stream\n\r");
	//		xil_printf("--- Exiting API ---\n\r");
	//		return XST_FAILURE;
		}
		xil_printf(" Test Succeeded. Output data matches input stream\n\r");
	//	xil_printf("--- Exiting API ---\n\r");
	//	return XST_SUCCESS;
	}
}

