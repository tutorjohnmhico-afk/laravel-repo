<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthTest extends TestCase
{
    public function test_the_health_page_responds(): void
    {
        $this->get('/up')->assertOk();
    }
}
