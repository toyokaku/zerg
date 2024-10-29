/*
 * @description
 * @author         ryutoyokaku
 * Copyright ©Pawgege LLC. All rights reserved.
 * Use of this source code is governed by a BSD-style license in the LICENSE file.
 */

package server

import (
	"context"
	"log"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

type ControlPlaneServer struct {
	k8sClient *kubernetes.Clientset
}

func NewControlPlaneServer(client *kubernetes.Clientset) *ControlPlaneServer {
	return &ControlPlaneServer{
		k8sClient: client,
	}
}

func (s *ControlPlaneServer) GetClusterHealth(ctx context.Context) error {
	nodes, err := s.k8sClient.CoreV1().Nodes().List(ctx, metav1.ListOptions{})
	if err != nil {
		return err
	}

	for _, node := range nodes.Items {
		log.Printf("Node: %s, Status: %v\n", node.Name, node.Status.Conditions)
	}
	return nil
}
