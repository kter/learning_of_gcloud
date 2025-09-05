package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerratest(t *testing.T) {
	options := &terraform.Options{
		TerraformDir: "../for_test",
		Vars: map[string]interface{}{
			"project_id": "playground-469814",
		},
	}
	
	terraform.Init(t, options)
	terraform.Apply(t, options)
	defer terraform.Destroy(t, options)
	
	// 出力をテスト
	instanceName := terraform.Output(t, options, "instance_name")
	t.Logf("Instance name: %s", instanceName)
}