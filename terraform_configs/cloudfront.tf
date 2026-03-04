resource "aws_cloudfront_distribution" "lamp_cdn" {
    origin {
        domain_name = aws_instance.lamp_instance.public_dns
        origin_id   = "lamp-origin"
    
        custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        }
    }
    
    enabled             = true
    comment             = "CDN for LAMP stack"
    default_root_object = "my-app.php"
    
    default_cache_behavior {
        target_origin_id       = "lamp-origin"
        viewer_protocol_policy = "redirect-to-https"
    
        allowed_methods = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
        cached_methods  = ["GET", "HEAD"]
    
        forwarded_values {
        query_string = true
    
        cookies {
            forward = "all"
        }
        }
    }
    
    price_class = "PriceClass_100"
    
    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }
    
    viewer_certificate {
        cloudfront_default_certificate = true
    }
  
}